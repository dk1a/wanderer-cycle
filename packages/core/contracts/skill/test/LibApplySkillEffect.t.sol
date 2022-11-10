// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Test } from "../../Test.sol";

import { World } from "solecs/World.sol";

import { SkillPrototypeComponent } from "../SkillPrototypeComponent.sol";
import { TBTimeScopeComponent } from "../../turn-based-time/TBTimeScopeComponent.sol";

import { LibApplySkillEffect } from "../LibApplySkillEffect.sol";
import { LibLearnedSkills } from "../LibLearnedSkills.sol";

// can't expectRevert internal calls, so this is an external wrapper
contract LibApplySkillEffectRevertHelper {
  using LibApplySkillEffect for LibApplySkillEffect.Self;

  function applySkillEffect(
    LibApplySkillEffect.Self memory _libASE,
    uint256 skillEntity,
    uint256 targetEntity
  ) public {
    _libASE.applySkillEffect(skillEntity, targetEntity);
  }
}

contract LibApplySkillEffectTest is Test {
  using LibApplySkillEffect for LibApplySkillEffect.Self;
  using LibLearnedSkills for LibLearnedSkills.Self;

  LibApplySkillEffect.Self _libASE;

  uint256 userEntity = uint256(keccak256('userEntity'));
  uint256 targetEntity = uint256(keccak256('targetEntity'));

  // sample skill entities
  uint256 chargePE = uint256(keccak256('Charge'));
  uint256 parryPE = uint256(keccak256('Parry'));
  uint256 cleavePE = uint256(keccak256('Cleave'));
  uint256 someInvalidSkillPE = uint256(keccak256('someInvalidSkill'));

  function setUp() public virtual override {
    super.setUp();

    // init library's object
    _libASE = LibApplySkillEffect.__construct(
      world.components(),
      userEntity
    );

    // learn sample skills
    _libASE.learnedSkills.learnSkill(chargePE);
    _libASE.learnedSkills.learnSkill(parryPE);
    _libASE.learnedSkills.learnSkill(cleavePE);
  }

  function testSampleSkillsLearned() public {
    assertTrue(_libASE.learnedSkills.hasSkill(chargePE));
    assertTrue(_libASE.learnedSkills.hasSkill(parryPE));
    assertTrue(_libASE.learnedSkills.hasSkill(cleavePE));
  }

  function testInvalidSkillNotLearned() public {
    assertFalse(_libASE.learnedSkills.hasSkill(someInvalidSkillPE));
  }

  function testApplyToInvalidTarget() public {
    LibApplySkillEffectRevertHelper _revertHelper = new LibApplySkillEffectRevertHelper();

    vm.expectRevert(LibApplySkillEffect.LibUseSkill__InvalidSkillTarget.selector);
    _revertHelper.applySkillEffect(_libASE, chargePE, targetEntity);
  }

  // TODO more tests when PStats are done
  /*function testApplyCharge() public {
    //_libASE.applySkillEffect(chargePE, userEntity);

  }*/
}