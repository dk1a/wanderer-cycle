// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Test } from "../../Test.sol";

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { World } from "solecs/World.sol";

import { SkillPrototypeComponent } from "../SkillPrototypeComponent.sol";
import { TBTimeScopeComponent } from "../../turn-based-time/TBTimeScopeComponent.sol";

import { LibSkill } from "../LibSkill.sol";
import { LibLearnedSkills } from "../LibLearnedSkills.sol";
import { LibCharstat, Element } from "../../charstat/LibCharstat.sol";
import { LibExperience, PStat, PS_L } from "../../charstat/LibExperience.sol";
import { LibEffect } from "../../effect/LibEffect.sol";
import { TBTime, TimeStruct } from "../../turn-based-time/TBTime.sol";

// can't expectRevert internal calls, so this is an external wrapper
contract LibSkillRevertHelper {
  using LibSkill for LibSkill.Self;

  function useSkill(
    LibSkill.Self memory libSkill,
    uint256 targetEntity
  ) public {
    libSkill.useSkill(targetEntity);
  }
}

contract LibSkillTest is Test {
  using LibSkill for LibSkill.Self;
  using LibLearnedSkills for LibLearnedSkills.Self;
  using LibCharstat for LibCharstat.Self;
  using LibEffect for LibEffect.Self;
  using TBTime for TBTime.Self;

  IUint256Component components;

  // helpers
  LibSkillRevertHelper revertHelper;

  // libs
  LibCharstat.Self charstat;
  LibLearnedSkills.Self learnedSkills;
  TBTime.Self tbtime;

  uint256 userEntity = uint256(keccak256('userEntity'));
  uint256 otherEntity = uint256(keccak256('otherEntity'));

  // sample skill entities
  uint256 cleavePE = uint256(keccak256('Cleave'));
  uint256 chargePE = uint256(keccak256('Charge'));
  uint256 parryPE = uint256(keccak256('Parry'));
  uint256 someInvalidSkillPE = uint256(keccak256('someInvalidSkill'));

  function setUp() public virtual override {
    super.setUp();

    components = world.components();
    // init helpers and libs
    revertHelper = new LibSkillRevertHelper();
    charstat = LibCharstat.__construct(components, userEntity);
    learnedSkills = LibLearnedSkills.__construct(components, userEntity);
    tbtime = TBTime.__construct(components, userEntity);

    // learn sample skills
    learnedSkills.learnSkill(cleavePE);
    learnedSkills.learnSkill(chargePE);
    learnedSkills.learnSkill(parryPE);

    // give user some mana
    charstat.setManaCurrent(4);
    // allow user to receive experience
    LibExperience.initExp(charstat.exp);
  }

  function _libSkill(
    uint256 skillEntity
  ) internal view returns (LibSkill.Self memory) {
    return LibSkill.__construct(components, userEntity, skillEntity);
  }

  function testSampleSkillsLearned() public {
    assertTrue(learnedSkills.hasSkill(cleavePE));
    assertTrue(learnedSkills.hasSkill(chargePE));
    assertTrue(learnedSkills.hasSkill(parryPE));
  }

  function testInvalidSkillNotLearned() public {
    assertFalse(learnedSkills.hasSkill(someInvalidSkillPE));
  }

  function testApplyToInvalidTarget() public {
    // user is the only valid target for charge
    LibSkill.Self memory libSkill = _libSkill(chargePE);
    vm.expectRevert(LibSkill.LibSkill__InvalidSkillTarget.selector);
    revertHelper.useSkill(libSkill, otherEntity);
  }

  // TODO mana stuff isn't very skill-related?
  function testInitialMana() public {
    assertEq(charstat.getMana(), 4);
  }

  function testNoManaOverflow() public {
    charstat.setManaCurrent(100);
    assertEq(charstat.getMana(), 4);
  }

  function testApplyCharge() public {
    _libSkill(chargePE).useSkill(userEntity);

    assertEq(charstat.getManaCurrent(), 4 - 1, "Invalid mana remainder");
    assertTrue(tbtime.has(chargePE), "No ongoing cooldown");

    LibEffect.Self memory libEffect = LibEffect.__construct(components, userEntity);
    assertTrue(libEffect.has(chargePE), "No ongoing effect");
  }

  function testCleaveEffect() public {
    _libSkill(cleavePE).useSkill(userEntity);
    assertEq(charstat.getAttack()[uint256(Element.PHYSICAL)], 3);
  }

  // str and the 2 skills should all modify physical attack,
  // test that it all stacks correctly
  function testCleaveChargeStrengthStacking() public {
    // add exp to get 2 str (which should increase base physical attack to 2)
    uint32[PS_L] memory addExp;
    addExp[uint256(PStat.STRENGTH)] = LibExperience.getExpForPStat(2);
    LibExperience.increaseExp(charstat.exp, addExp);

    // 16%, +2
    LibSkill.Self memory libSkill = _libSkill(cleavePE);
    libSkill.useSkill(userEntity);
    // 64%
    libSkill.switchSkill(chargePE);
    libSkill.useSkill(userEntity);
    // 2 * 1.8 + 2
    assertEq(charstat.getAttack()[uint256(Element.PHYSICAL)], 5);
  }

  // this tests durations, especially TBTime's effect removal callback
  // TODO a lot of this can be removed if effects get their own tests,
  // atm the many assertions help tell apart bugs in effects and tbtime
  function testCleaveChargeDurationEnd() public {
    // add exp to get 2 str (which should increase base physical attack to 2)
    uint32[PS_L] memory addExp;
    addExp[uint256(PStat.STRENGTH)] = LibExperience.getExpForPStat(2);
    LibExperience.increaseExp(charstat.exp, addExp);

    assertEq(charstat.getAttack()[uint256(Element.PHYSICAL)], 2);

    LibEffect.Self memory libEffect = LibEffect.__construct(components, userEntity);

    LibSkill.Self memory libSkill = _libSkill(cleavePE);
    libSkill.useSkill(userEntity);
    libSkill = libSkill.switchSkill(chargePE);
    libSkill.useSkill(userEntity);

    assertTrue(tbtime.has(libEffect._appliedEntity(cleavePE)));
    assertTrue(tbtime.has(libEffect._appliedEntity(chargePE)));
    assertEq(charstat.getAttack()[uint256(Element.PHYSICAL)], 5);

    // decrease cleave duration and cooldown
    tbtime.decreaseTopic(
      TimeStruct({
        timeTopic: bytes4(keccak256("round")),
        timeValue: 1
      })
    );

    // cooldown
    assertFalse(tbtime.has(cleavePE));
    // effect
    assertFalse(tbtime.has(libEffect._appliedEntity(cleavePE)));
    assertTrue(tbtime.has(libEffect._appliedEntity(chargePE)));
    assertEq(charstat.getAttack()[uint256(Element.PHYSICAL)], 3);

    // decrease charge duration
    tbtime.decreaseTopic(
      TimeStruct({
        timeTopic: bytes4(keccak256("round_persistent")),
        timeValue: 1
      })
    );

    assertFalse(tbtime.has(libEffect._appliedEntity(cleavePE)));
    assertFalse(tbtime.has(libEffect._appliedEntity(chargePE)));
    assertEq(charstat.getAttack()[uint256(Element.PHYSICAL)], 2);
  }
}