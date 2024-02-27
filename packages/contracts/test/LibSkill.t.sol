// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { GenericDuration, GenericDurationData, EffectDurationTableId, DurationIdxMap, SkillCooldownTableId, EffectDuration } from "../src/codegen/index.sol";
import { EleStat, SkillType, TargetType, StatmodOp } from "../src/codegen/common.sol";
import { PStat, PStat_length, StatmodOp_length, EleStat_length, StatmodOpFinal } from "../src/CustomTypes.sol";

import { Duration } from "../src/modules/duration/Duration.sol";
import { LibLearnedSkills } from "../src/skill/LibLearnedSkills.sol";
import { LibSkill } from "../src/skill/LibSkill.sol";
import { LibCharstat } from "../src/charstat/LibCharstat.sol";
import { LibExperience } from "../src/charstat/LibExperience.sol";
import { LibEffect } from "../src/modules/effect/LibEffect.sol";

// can't expectRevert internal calls, so this is an external wrapper
// contract LibSkillRevertHelper {
//   function useSkill(bytes32 userEntity, bytes32 skillEntity, bytes32 targetEntity) public {
//     LibSkill.useSkill(userEntity, skillEntity, targetEntity);
//   }
// }

contract LibSkillTest is MudLibTest {
  bytes32 userEntity = keccak256("userEntity");
  bytes32 targetEntity = keccak256("targetEntity");

  // sample skill entities
  bytes32 cleavePE = keccak256("Cleave");
  bytes32 chargePE = keccak256("Charge");
  bytes32 parryPE = keccak256("Parry");
  bytes32 someInvalidSkillPE = keccak256("someInvalidSkill");

  bytes32 round = keccak256("round");
  bytes32 round_persistent = keccak256("round_persistent");

  function setUp() public virtual override {
    super.setUp();
    // init helpers and libs
    // revertHelper = new LibSkillRevertHelper();

    // give user some mana
    LibCharstat.setManaCurrent(userEntity, 4);
    // allow user to receive experience
    LibExperience.initExp(userEntity);

    // learn sample skills
    LibLearnedSkills.learnSkill(userEntity, cleavePE, targetEntity);
    LibLearnedSkills.learnSkill(userEntity, chargePE, targetEntity);
    LibLearnedSkills.learnSkill(userEntity, parryPE, targetEntity);
  }

  function test_setUp() public {
    assertTrue(LibLearnedSkills.hasSkill(userEntity, cleavePE));
    assertTrue(LibLearnedSkills.hasSkill(userEntity, chargePE));
    assertTrue(LibLearnedSkills.hasSkill(userEntity, parryPE));

    assertEq(LibCharstat.getMana(userEntity), 4);
  }

  function test_hasSkill_invalidSkill() public {
    assertFalse(LibLearnedSkills.hasSkill(userEntity, someInvalidSkillPE));
  }

  // function test_useSkill_invalidTarget() public {
  //   // user is the only valid target for charge
  //   LibSkill.Self memory libSkill = _libSkill(chargePE);
  //   vm.expectRevert(LibSkill.LibSkill__InvalidSkillTarget.selector);
  //   revertHelper.useSkill(libSkill, otherEntity);
  // }

  // TODO mana stuff isn't very skill-related?
  function test_setManaCurrent_capped() public {
    LibCharstat.setManaCurrent(userEntity, 100);
    assertEq(LibCharstat.getMana(userEntity), 4);
  }

  function test_useSkill_Charge() public {
    LibSkill.useSkill(userEntity, chargePE, targetEntity);

    assertEq(LibCharstat.getManaCurrent(userEntity), 4 - 1, "Invalid mana remainder");
    assertTrue(Duration.has(SkillCooldownTableId, targetEntity, chargePE), "No ongoing cooldown");
    assertTrue(LibEffect.hasEffectApplied(userEntity, chargePE), "No ongoing effect");
  }

  function test_useSkill_Cleave_effect() public {
    LibSkill.useSkill(userEntity, cleavePE, targetEntity);
    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 3);
  }

  // str and the 2 skills should all modify physical attack,
  // test that it all stacks correctly
  // TODO SwitchSkill?
  function test_useSkill_CleaveAndCharge_strengthStacking() public {
    // add exp to get 2 str (which should increase base physical attack to 2)
    uint32[PStat_length] memory addExp;
    addExp[uint256(PStat.STRENGTH)] = LibExperience.getExpForPStats(2);
    LibExperience.increaseExp(userEntity, addExp);

    // 16%, +2
    LibSkill.useSkill(userEntity, cleavePE, targetEntity);
    // 64%
    LibSkill.switchSkill(userEntity, chargePE, targetEntity);
    LibSkill.useSkill(userEntity, chargePE, targetEntity);
    // 2 * 1.8 + 2
    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 5);
  }

  // this tests durations, especially DurationSubSystem's effect removal callback
  // TODO a lot of this can be removed if effects get their own tests,
  // atm the many assertions help tell apart bugs in effectSubSystem and durationSubSystem
  function test_useSkill_CleaveAndCharge_onDurationEnd() public {
    // add exp to get 2 str (which should increase base physical attack to 2)
    uint32[PStat_length] memory addExp;
    addExp[uint256(PStat.STRENGTH)] = LibExperience.getExpForPStat(2);
    LibExperience.increaseExp(userEntity, addExp);

    assertEq(LibCharstat.getAttack(targetEntity)[uint256(EleStat.PHYSICAL)], 2);
    // TODO SwitchSkill?
    LibSkill.useSkill(userEntity);
    libSkill = libSkill.switchSkill(chargePE);
    LibSkill.useSkill(userEntity);

    assertTrue(Duration.has(EffectDurationTableId, userEntity, cleavePE));
    assertTrue(Duration.has(EffectDurationTableId, userEntity, chargePE));
    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 5);

    // decrease cleave duration and cooldown
    Duration.decreaseApplications(
      SkillCooldownTableId,
      targetEntity,
      GenericDurationData({ timeId: round, timeValue: 1 })
    );

    // cooldown
    assertFalse(Duration.has(SkillCooldownTableId, userEntity, chargePE));
    // effect
    assertFalse(Duration.has(EffectDurationTableId, userEntity, cleavePE));
    assertTrue(Duration.has(EffectDurationTableId, userEntity, chargePE));
    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 3);

    // decrease charge duration
    Duration.decreaseApplications(
      SkillCooldownTableId,
      targetEntity,
      GenericDurationData({ timeId: round_persistent, timeValue: 1 })
    );

    assertFalse(Duration.has(EffectDurationTableId, userEntity, cleavePE));
    assertTrue(Duration.has(EffectDurationTableId, userEntity, chargePE));
    assertEq(LibCharstat.getAttack(userEntity)[uint256(EleStat.PHYSICAL)], 2);
  }
}
