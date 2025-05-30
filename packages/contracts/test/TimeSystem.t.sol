// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";
import { BaseTest } from "./BaseTest.t.sol";

import { Duration, GenericDurationData } from "../src/namespaces/duration/Duration.sol";
import { charstatSystem } from "../src/namespaces/charstat/codegen/systems/CharstatSystemLib.sol";
import { skillSystem } from "../src/namespaces/skill/codegen/systems/SkillSystemLib.sol";
import { learnSkillSystem } from "../src/namespaces/skill/codegen/systems/LearnSkillSystemLib.sol";
import { timeSystem } from "../src/namespaces/time/codegen/systems/TimeSystemLib.sol";
import { LibSOFClass } from "../src/namespaces/common/LibSOFClass.sol";
import { LibSkill } from "../src/namespaces/skill/LibSkill.sol";
import { LibCharstat } from "../src/namespaces/charstat/LibCharstat.sol";
import { EffectDuration } from "../src/namespaces/effect/codegen/tables/EffectDuration.sol";
import { SkillCooldown } from "../src/namespaces/skill/codegen/tables/SkillCooldown.sol";
import { SkillName } from "../src/namespaces/skill/codegen/tables/SkillName.sol";

contract TimeSystemTest is BaseTest {
  bytes32 userEntity;

  // sample skill entities
  bytes32 cleaveEntity;
  bytes32 chargeEntity;
  bytes32 parryEntity;
  bytes32 onslaughtEntity;
  bytes32 retaliationEntity;
  bytes32 lastStandEntity;

  function setUp() public virtual override {
    super.setUp();

    _addToScope("test", learnSkillSystem.toResourceId());
    _addToScope("test", skillSystem.toResourceId());

    cleaveEntity = LibSkill.getSkillEntity("Cleave");
    chargeEntity = LibSkill.getSkillEntity("Charge");
    parryEntity = LibSkill.getSkillEntity("Parry");
    onslaughtEntity = LibSkill.getSkillEntity("Onslaught");
    retaliationEntity = LibSkill.getSkillEntity("Retaliation");
    lastStandEntity = LibSkill.getSkillEntity("Last Stand");

    vm.startPrank(deployer);

    userEntity = LibSOFClass.instantiate("test", deployer);

    // allow user to receive experience, so it has 1 in all pstats at the default level 1
    charstatSystem.initExp(userEntity);
    // give user some mana (this will not be enough because it's capped by max mana)
    charstatSystem.setManaCurrent(userEntity, 1000);

    // learn sample skills
    learnSkillSystem.learnSkill(userEntity, cleaveEntity);
    learnSkillSystem.learnSkill(userEntity, chargeEntity);
    learnSkillSystem.learnSkill(userEntity, parryEntity);
    learnSkillSystem.learnSkill(userEntity, onslaughtEntity);
    learnSkillSystem.learnSkill(userEntity, retaliationEntity);
    learnSkillSystem.learnSkill(userEntity, lastStandEntity);

    vm.stopPrank();
  }

  function assertDuration(
    ResourceId tableId,
    bytes32 applicationEntity,
    GenericDurationData memory duration
  ) internal view {
    string memory skillName = SkillName.get(applicationEntity);
    string memory errorPrefix = string.concat(string(abi.encodePacked(tableId.getResourceName())), " ", skillName, " ");

    if (duration.timeValue == 0) {
      assertFalse(
        Duration.has(tableId, userEntity, applicationEntity),
        string.concat(errorPrefix, "duration must be absent for timeValue == 0")
      );
      assertEq(duration.timeId, "", string.concat(errorPrefix, "timeId must be empty for timeValue == 0"));
    } else {
      assertTrue(
        Duration.has(tableId, userEntity, applicationEntity),
        string.concat(errorPrefix, "duration must be present for timeValue != 0")
      );
    }
    assertEq(Duration.get(tableId, userEntity, applicationEntity), duration, errorPrefix);
  }

  function assertDurations(
    bytes32 applicationEntity,
    GenericDurationData memory skillCooldown,
    GenericDurationData memory effectDuration
  ) internal view {
    assertDuration(SkillCooldown._tableId, applicationEntity, skillCooldown);
    assertDuration(EffectDuration._tableId, applicationEntity, effectDuration);
  }

  function testRevertUnscoped() public {
    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, userEntity, emptySystemId)
    );
    emptySystemMock.time__passRounds(userEntity, 1);

    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, userEntity, emptySystemId)
    );
    emptySystemMock.time__passTurns(userEntity, 1);
  }

  function testPassiveSkillNoDuration() public {
    scopedSystemMock.skill__useSkill(userEntity, parryEntity, userEntity);
    assertDurations(parryEntity, GenericDurationData("", 0), GenericDurationData("", 0));
  }

  function testManyDurations() public {
    scopedSystemMock.skill__useSkill(userEntity, cleaveEntity, userEntity);
    scopedSystemMock.skill__useSkill(userEntity, chargeEntity, userEntity);
    scopedSystemMock.skill__useSkill(userEntity, onslaughtEntity, userEntity);
    scopedSystemMock.skill__useSkill(userEntity, retaliationEntity, userEntity);

    assertDurations(cleaveEntity, GenericDurationData("round", 1), GenericDurationData("round", 1));
    assertDurations(chargeEntity, GenericDurationData("turn", 3), GenericDurationData("round_persistent", 1));
    assertDurations(onslaughtEntity, GenericDurationData("turn", 16), GenericDurationData("round_persistent", 8));
    assertDurations(retaliationEntity, GenericDurationData("turn", 16), GenericDurationData("turn", 1));

    scopedSystemMock.time__passTurns(userEntity, 1);

    assertDurations(cleaveEntity, GenericDurationData("", 0), GenericDurationData("", 0));
    assertDurations(chargeEntity, GenericDurationData("turn", 2), GenericDurationData("round_persistent", 1));
    assertDurations(onslaughtEntity, GenericDurationData("turn", 15), GenericDurationData("round_persistent", 8));
    assertDurations(retaliationEntity, GenericDurationData("turn", 15), GenericDurationData("", 0));

    // more mana for remaining skills
    vm.startPrank(deployer);
    charstatSystem.setManaCurrent(userEntity, 4);

    scopedSystemMock.skill__useSkill(userEntity, cleaveEntity, userEntity);
    scopedSystemMock.skill__useSkill(userEntity, lastStandEntity, userEntity);
    vm.stopPrank();

    assertDurations(cleaveEntity, GenericDurationData("round", 1), GenericDurationData("round", 1));
    assertDurations(lastStandEntity, GenericDurationData("turn", 8), GenericDurationData("round", 4));

    scopedSystemMock.time__passRounds(userEntity, 1);

    assertDurations(cleaveEntity, GenericDurationData("", 0), GenericDurationData("", 0));
    assertDurations(chargeEntity, GenericDurationData("turn", 2), GenericDurationData("", 0));
    assertDurations(onslaughtEntity, GenericDurationData("turn", 15), GenericDurationData("round_persistent", 7));
    assertDurations(retaliationEntity, GenericDurationData("turn", 15), GenericDurationData("", 0));
    assertDurations(lastStandEntity, GenericDurationData("turn", 8), GenericDurationData("round", 3));

    // test using direct access in between scoped system-to-system calls
    vm.prank(deployer);
    timeSystem.passTurns(userEntity, 15);

    assertDurations(cleaveEntity, GenericDurationData("", 0), GenericDurationData("", 0));
    assertDurations(chargeEntity, GenericDurationData("", 0), GenericDurationData("", 0));
    assertDurations(onslaughtEntity, GenericDurationData("", 0), GenericDurationData("round_persistent", 7));
    assertDurations(retaliationEntity, GenericDurationData("", 0), GenericDurationData("", 0));
    assertDurations(lastStandEntity, GenericDurationData("", 0), GenericDurationData("", 0));

    scopedSystemMock.skill__useSkill(userEntity, lastStandEntity, userEntity);
    assertDurations(lastStandEntity, GenericDurationData("turn", 8), GenericDurationData("round", 4));
    scopedSystemMock.time__passTurns(userEntity, 1);
    assertDurations(lastStandEntity, GenericDurationData("turn", 7), GenericDurationData("", 0));
  }
}
