// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";
import { BaseTest } from "./BaseTest.t.sol";
import { SkillCooldown } from "../src/namespaces/skill/codegen/index.sol";
import { EleStat, SkillType, TargetType, StatmodOp } from "../src/codegen/common.sol";
import { PStat, PStat_length, StatmodOp_length, EleStat_length, StatmodOpFinal } from "../src/CustomTypes.sol";

import { Duration, GenericDuration, GenericDurationData } from "../src/namespaces/duration/Duration.sol";
import { charstatSystem } from "../src/namespaces/charstat/codegen/systems/CharstatSystemLib.sol";
import { skillSystem } from "../src/namespaces/skill/codegen/systems/SkillSystemLib.sol";
import { learnSkillSystem } from "../src/namespaces/skill/codegen/systems/LearnSkillSystemLib.sol";
import { LibSOFClass } from "../src/namespaces/common/LibSOFClass.sol";
import { LibSkill } from "../src/namespaces/skill/LibSkill.sol";
import { LibCharstat } from "../src/namespaces/charstat/LibCharstat.sol";
import { LibExperience } from "../src/namespaces/charstat/LibExperience.sol";
import { LibEffect, EffectDuration } from "../src/namespaces/effect/LibEffect.sol";
import { TestSystem } from "./TestSystem.sol";

contract SkillSystemTest is BaseTest {
  bytes32 userEntity;

  // sample skill entities
  bytes32 cleavePE;
  bytes32 chargePE;
  bytes32 parryPE;
  bytes32 someInvalidSkillPE = keccak256("someInvalidSkill");

  bytes32 round = "round";
  bytes32 round_persistent = "round_persistent";

  function setUp() public virtual override {
    super.setUp();

    _addToScope("test", learnSkillSystem.toResourceId());
    _addToScope("test", skillSystem.toResourceId());

    cleavePE = LibSkill.getSkillEntity("Cleave");
    chargePE = LibSkill.getSkillEntity("Charge");
    parryPE = LibSkill.getSkillEntity("Parry");

    vm.startPrank(deployer);

    userEntity = LibSOFClass.instantiate("test", deployer);

    // give user some mana
    charstatSystem.setManaCurrent(userEntity, 4);
    // allow user to receive experience
    charstatSystem.initExp(userEntity);

    // learn sample skills
    learnSkillSystem.learnSkill(userEntity, cleavePE);
    learnSkillSystem.learnSkill(userEntity, chargePE);
    learnSkillSystem.learnSkill(userEntity, parryPE);

    vm.stopPrank();
  }

  function testSetUp() public view {
    // must return true for all learned skills
    assertTrue(LibSkill.hasSkill(userEntity, cleavePE));
    assertTrue(LibSkill.hasSkill(userEntity, chargePE));
    assertTrue(LibSkill.hasSkill(userEntity, parryPE));
    // must return false for not learned skills
    assertFalse(LibSkill.hasSkill(userEntity, someInvalidSkillPE));
  }

  function testRevertUnscoped() public {
    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, userEntity, emptySystemId)
    );
    emptySystemMock.skill__useSkill(userEntity, cleavePE, userEntity);
  }

  function testUseSkillInvalidTarget() public {
    // user is the only valid target for charge
    vm.expectPartialRevert(LibSkill.LibSkill_InvalidUserAndTargetCombination.selector);
    scopedSystemMock.skill__useSkill(userEntity, chargePE, keccak256("invalidEntity"));
  }

  function testUseSkillCharge() public {
    scopedSystemMock.skill__useSkill(userEntity, chargePE, userEntity);

    assertEq(LibCharstat.getManaCurrent(userEntity), 4 - 1, "Invalid mana remainder");
    assertTrue(Duration.has(SkillCooldown._tableId, userEntity, chargePE), "No ongoing cooldown");
    assertTrue(LibEffect.hasEffectApplied(userEntity, chargePE), "No ongoing effect");
  }

  function testUseSkillCleaveEffect() public {
    scopedSystemMock.skill__useSkill(userEntity, cleavePE, userEntity);
    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 3);
  }

  // str and the 2 skills should all modify physical attack,
  // test that it all stacks correctly
  function testUseSkillCleaveAndChargeStrengthStacking() public {
    // add exp to get 2 str (which should increase base physical attack to 2)
    uint32[PStat_length] memory addExp;
    addExp[uint256(PStat.STRENGTH)] = LibExperience.getExpForPStat(2);
    scopedSystemMock.charstat__increaseExp(userEntity, addExp);

    // 16%, +2
    scopedSystemMock.skill__useSkill(userEntity, cleavePE, userEntity);
    // 64%
    scopedSystemMock.skill__useSkill(userEntity, chargePE, userEntity);
    // 2 * 1.8 + 2
    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 5);
  }

  // this tests durations, especially EffectDurationHook
  function testUseSkillCleaveAndChargeEffectDurationHook() public {
    // add exp to get 2 str (which should increase base physical attack to 2)
    uint32[PStat_length] memory addExp;
    addExp[uint256(PStat.STRENGTH)] = LibExperience.getExpForPStat(2);
    scopedSystemMock.charstat__increaseExp(userEntity, addExp);

    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 2);
    scopedSystemMock.skill__useSkill(userEntity, cleavePE, userEntity);
    scopedSystemMock.skill__useSkill(userEntity, chargePE, userEntity);

    assertTrue(Duration.has(EffectDuration._tableId, userEntity, cleavePE));
    assertTrue(Duration.has(EffectDuration._tableId, userEntity, chargePE));
    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 5);

    // decrease cleave duration
    Duration.decreaseApplications(
      EffectDuration._tableId,
      userEntity,
      GenericDurationData({ timeId: round, timeValue: 1 })
    );

    assertFalse(Duration.has(EffectDuration._tableId, userEntity, cleavePE));
    assertTrue(Duration.has(EffectDuration._tableId, userEntity, chargePE));
    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 3);

    // decrease charge duration
    Duration.decreaseApplications(
      EffectDuration._tableId,
      userEntity,
      GenericDurationData({ timeId: round_persistent, timeValue: 1 })
    );

    assertFalse(Duration.has(EffectDuration._tableId, userEntity, cleavePE));
    assertFalse(Duration.has(EffectDuration._tableId, userEntity, chargePE));
    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 2);
  }
}
