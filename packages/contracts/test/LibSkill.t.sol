// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { BaseTest } from "./BaseTest.t.sol";
import { SkillCooldown } from "../src/namespaces/root/codegen/index.sol";
import { EleStat, SkillType, TargetType, StatmodOp } from "../src/codegen/common.sol";
import { PStat, PStat_length, StatmodOp_length, EleStat_length, StatmodOpFinal } from "../src/CustomTypes.sol";

import { Duration, GenericDuration, GenericDurationData } from "../src/namespaces/duration/Duration.sol";
import { LibLearnedSkills } from "../src/namespaces/root/skill/LibLearnedSkills.sol";
import { LibSkill } from "../src/namespaces/root/skill/LibSkill.sol";
import { LibCharstat } from "../src/namespaces/root/charstat/LibCharstat.sol";
import { LibExperience } from "../src/namespaces/root/charstat/LibExperience.sol";
import { LibEffect, EffectDuration } from "../src/namespaces/effect/LibEffect.sol";
import { TestSystem } from "./TestSystem.sol";

contract SkillTestSystem is TestSystem {
  constructor(address worldAddress) TestSystem(worldAddress) {}

  function useSkill(bytes32 userEntity, bytes32 skillEntity, bytes32 targetEntity) public {
    LibSkill.useSkill(userEntity, skillEntity, targetEntity);
  }
}

contract LibSkillTest is BaseTest {
  SkillTestSystem skillTestSystem;

  bytes32 userEntity = keccak256("userEntity");

  // sample skill entities
  bytes32 cleavePE;
  bytes32 chargePE;
  bytes32 parryPE;
  bytes32 someInvalidSkillPE = keccak256("someInvalidSkill");

  bytes32 round = "round";
  bytes32 round_persistent = "round_persistent";

  function setUp() public virtual override {
    super.setUp();
    // init helpers and libs
    skillTestSystem = new SkillTestSystem(worldAddress);

    cleavePE = LibSkill.getSkillEntity("Cleave");
    chargePE = LibSkill.getSkillEntity("Charge");
    parryPE = LibSkill.getSkillEntity("Parry");

    // give user some mana
    LibCharstat.setManaCurrent(userEntity, 4);
    // allow user to receive experience
    LibExperience.initExp(userEntity);

    // learn sample skills
    LibLearnedSkills.learnSkill(userEntity, cleavePE);
    LibLearnedSkills.learnSkill(userEntity, chargePE);
    LibLearnedSkills.learnSkill(userEntity, parryPE);
  }

  function testSetUp() public {
    assertTrue(LibLearnedSkills.hasSkill(userEntity, cleavePE));
    assertTrue(LibLearnedSkills.hasSkill(userEntity, chargePE));
    assertTrue(LibLearnedSkills.hasSkill(userEntity, parryPE));

    assertEq(LibCharstat.getMana(userEntity), 4);
  }

  function testHasSkillInvalidSkill() public {
    assertFalse(LibLearnedSkills.hasSkill(userEntity, someInvalidSkillPE));
  }

  function testUseSkillInvalidTarget() public {
    // user is the only valid target for charge
    vm.expectPartialRevert(LibSkill.LibSkill_InvalidSkillTarget.selector);
    skillTestSystem.useSkill(userEntity, chargePE, keccak256("invalidEntity"));
  }

  // TODO mana stuff isn't very skill-related?
  function testSetManaCurrentCapped() public {
    LibCharstat.setManaCurrent(userEntity, 100);
    assertEq(LibCharstat.getMana(userEntity), 4);
  }

  function testUseSkillCharge() public {
    LibSkill.useSkill(userEntity, chargePE, userEntity);

    assertEq(LibCharstat.getManaCurrent(userEntity), 4 - 1, "Invalid mana remainder");
    assertTrue(Duration.has(SkillCooldown._tableId, userEntity, chargePE), "No ongoing cooldown");
    assertTrue(LibEffect.hasEffectApplied(userEntity, chargePE), "No ongoing effect");
  }

  function testUseSkillCleaveEffect() public {
    LibSkill.useSkill(userEntity, cleavePE, userEntity);
    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 3);
  }

  // str and the 2 skills should all modify physical attack,
  // test that it all stacks correctly
  function testUseSkillCleaveAndChargeStrengthStacking() public {
    // add exp to get 2 str (which should increase base physical attack to 2)
    uint32[PStat_length] memory addExp;
    addExp[uint256(PStat.STRENGTH)] = LibExperience.getExpForPStat(2);
    LibExperience.increaseExp(userEntity, addExp);

    // 16%, +2
    LibSkill.useSkill(userEntity, cleavePE, userEntity);
    // 64%
    LibSkill.useSkill(userEntity, chargePE, userEntity);
    // 2 * 1.8 + 2
    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 5);
  }

  // this tests durations, especially EffectDurationHook
  function testUseSkillCleaveAndChargeEffectDurationHook() public {
    // add exp to get 2 str (which should increase base physical attack to 2)
    uint32[PStat_length] memory addExp;
    addExp[uint256(PStat.STRENGTH)] = LibExperience.getExpForPStat(2);
    LibExperience.increaseExp(userEntity, addExp);

    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 2);
    LibSkill.useSkill(userEntity, cleavePE, userEntity);
    LibSkill.useSkill(userEntity, chargePE, userEntity);

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
