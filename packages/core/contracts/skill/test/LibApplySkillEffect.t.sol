// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Test } from "../../Test.sol";

import { World } from "solecs/World.sol";

import { SkillPrototypeComponent } from "../SkillPrototypeComponent.sol";
import { TBTimeScopeComponent } from "../../turn-based-time/TBTimeScopeComponent.sol";

import { LibApplySkillEffect } from "../LibApplySkillEffect.sol";
import { LibLearnedSkills } from "../LibLearnedSkills.sol";
import { LibCharstat, Element } from "../../charstat/LibCharstat.sol";
import { LibExperience, PStat, PS_L } from "../../charstat/LibExperience.sol";
import { LibEffect } from "../../effect/LibEffect.sol";
import { TBTime, TimeStruct } from "../../turn-based-time/TBTime.sol";

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
  using LibCharstat for LibCharstat.Self;
  using LibEffect for LibEffect.Self;

  LibApplySkillEffect.Self _libASE;

  uint256 userEntity = uint256(keccak256('userEntity'));
  uint256 targetEntity = uint256(keccak256('targetEntity'));

  // sample skill entities
  uint256 cleavePE = uint256(keccak256('Cleave'));
  uint256 chargePE = uint256(keccak256('Charge'));
  uint256 parryPE = uint256(keccak256('Parry'));
  uint256 someInvalidSkillPE = uint256(keccak256('someInvalidSkill'));

  function setUp() public virtual override {
    super.setUp();

    // init library's object
    _libASE = LibApplySkillEffect.__construct(
      world.components(),
      userEntity
    );

    // learn sample skills
    _libASE.learnedSkills.learnSkill(cleavePE);
    _libASE.learnedSkills.learnSkill(chargePE);
    _libASE.learnedSkills.learnSkill(parryPE);

    // give user some mana
    _libASE.charstat.setManaCurrent(4);
    // allow user to receive experience
    LibExperience.initExp(_libASE.charstat.exp);
  }

  function testSampleSkillsLearned() public {
    assertTrue(_libASE.learnedSkills.hasSkill(cleavePE));
    assertTrue(_libASE.learnedSkills.hasSkill(chargePE));
    assertTrue(_libASE.learnedSkills.hasSkill(parryPE));
  }

  function testInvalidSkillNotLearned() public {
    assertFalse(_libASE.learnedSkills.hasSkill(someInvalidSkillPE));
  }

  function testApplyToInvalidTarget() public {
    LibApplySkillEffectRevertHelper _revertHelper = new LibApplySkillEffectRevertHelper();

    vm.expectRevert(LibApplySkillEffect.LibUseSkill__InvalidSkillTarget.selector);
    _revertHelper.applySkillEffect(_libASE, chargePE, targetEntity);
  }

  // TODO mana stuff isn't very skill-related?
  function testInitialMana() public {
    assertEq(_libASE.charstat.getMana(), 4);
  }

  function testNoManaOverflow() public {
    _libASE.charstat.setManaCurrent(100);
    assertEq(_libASE.charstat.getMana(), 4);
  }

  function testApplyCharge() public {
    _libASE.applySkillEffect(chargePE, userEntity);

    assertEq(_libASE.charstat.getManaCurrent(), 4 - 1, "Invalid mana remainder");
    assertTrue(TBTime.has(_libASE.tbtime, chargePE), "No ongoing cooldown");

    LibEffect.Self memory libEffect = LibEffect.__construct(world.components(), userEntity);
    assertTrue(libEffect.has(chargePE), "No ongoing effect");
  }

  function testCleaveEffect() public {
    _libASE.applySkillEffect(cleavePE, userEntity);
    assertEq(_libASE.charstat.getAttack()[uint256(Element.PHYSICAL)], 3);
  }

  // str and the 2 skills should all modify physical attack,
  // test that it all stacks correctly
  function testCleaveChargeStrengthStacking() public {
    // add exp to get 2 str (which should increase base physical attack to 2)
    uint32[PS_L] memory addExp;
    addExp[uint256(PStat.STRENGTH)] = LibExperience.getExpForPStat(2);
    LibExperience.increaseExp(_libASE.charstat.exp, addExp);

    // 16%, +2
    _libASE.applySkillEffect(cleavePE, userEntity);
    // 64%
    _libASE.applySkillEffect(chargePE, userEntity);
    // 2 * 1.8 + 2
    assertEq(_libASE.charstat.getAttack()[uint256(Element.PHYSICAL)], 5);
  }

  function testCleaveChargeDurationEnd() public {
    // add exp to get 2 str (which should increase base physical attack to 2)
    uint32[PS_L] memory addExp;
    addExp[uint256(PStat.STRENGTH)] = LibExperience.getExpForPStat(2);
    LibExperience.increaseExp(_libASE.charstat.exp, addExp);

    _libASE.applySkillEffect(cleavePE, userEntity);
    _libASE.applySkillEffect(chargePE, userEntity);

    // pass 1 round (which should be the duration for cleave and charge)
    TBTime.decreaseTopic(
      TBTime.__construct(world.components(), userEntity),
      TimeStruct({
        timeTopic: bytes4(keccak256("round")),
        timeValue: 1
      })
    );
    TBTime.decreaseTopic(
      TBTime.__construct(world.components(), userEntity),
      TimeStruct({
        timeTopic: bytes4(keccak256("round_persistent")),
        timeValue: 1
      })
    );

    assertEq(_libASE.charstat.getAttack()[uint256(Element.PHYSICAL)], 2);
  }
}