// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";
import { BaseTest } from "./BaseTest.t.sol";

import { cycleControlSystem } from "../src/namespaces/cycle/codegen/systems/CycleControlSystemLib.sol";
import { cycleLearnSkillSystem } from "../src/namespaces/cycle/codegen/systems/CycleLearnSkillSystemLib.sol";
import { permSkillSystem } from "../src/namespaces/wanderer/codegen/systems/PermSkillSystemLib.sol";

import { LibGuise } from "../src/namespaces/root/guise/LibGuise.sol";
import { LibSkill } from "../src/namespaces/skill/LibSkill.sol";
import { LibCycle } from "../src/namespaces/cycle/LibCycle.sol";
import { LibCycleTurns } from "../src/namespaces/cycle/LibCycleTurns.sol";
import { ActiveCycle, CycleOwner, CompletedCycleHistory, BossesDefeated, RequiredBossMaps } from "../src/namespaces/cycle/codegen/index.sol";
import { LearnedSkills } from "../src/namespaces/skill/codegen/index.sol";
import { ActiveWheel, CompletedWheelCount, IdentityCurrent, IdentityEarnedTotal } from "../src/namespaces/wheel/codegen/index.sol";
import { IDENTITY_INCREMENT } from "../src/namespaces/wheel/constants.sol";

contract CycleTest is BaseTest {
  bytes32 internal guiseEntity;
  bytes32 internal wandererEntity;
  bytes32 internal cycleEntity;
  bytes32 internal wheelEntity;
  bytes32 internal skillEntity;

  function setUp() public virtual override {
    super.setUp();

    _addToScope("cycle", scopedSystemId);

    guiseEntity = LibGuise.getGuiseEntity("Warrior");
    skillEntity = LibSkill.getSkillEntity("Cleave");
    (wandererEntity, cycleEntity) = world.wanderer__spawnWanderer(guiseEntity);

    wheelEntity = ActiveWheel.getWheelEntity(cycleEntity);
  }

  function _setRequirements(bytes32 _cycleEntity) internal {
    BossesDefeated.set(_cycleEntity, RequiredBossMaps.get());
    scopedSystemMock.charstat__increaseExp(_cycleEntity, [uint32(100000), 100000, 100000]);
  }

  function testSetUp() public view {
    assertNotEq(wheelEntity, bytes32(0));
    assertEq(ActiveCycle.get(wandererEntity), cycleEntity);
    assertEq(CycleOwner.get(cycleEntity), wandererEntity);
    assertEq(RequiredBossMaps.length(), 12);
  }

  function testAdminMintLoot() public {
    world.cycle__adminMintLoot(cycleEntity, 5, 4);
  }

  function testCompleteCycle() public {
    _setRequirements(cycleEntity);
    cycleControlSystem.completeCycle(cycleEntity);

    assertEq(ActiveCycle.get(wandererEntity), bytes32(0));
    assertEq(CycleOwner.get(cycleEntity), wandererEntity);
    assertEq(CompletedWheelCount.get(wandererEntity, wheelEntity), 1);
    assertEq(CompletedCycleHistory.length(wandererEntity), 1);
    assertEq(CompletedCycleHistory.getItem(wandererEntity, 0), cycleEntity);
    assertEq(IdentityCurrent.get(wandererEntity), IDENTITY_INCREMENT);
    assertEq(IdentityEarnedTotal.get(wandererEntity), IDENTITY_INCREMENT);
  }

  function testCancelCycle() public {
    cycleControlSystem.cancelCycle(cycleEntity);

    assertEq(ActiveCycle.get(wandererEntity), bytes32(0));
    assertEq(CycleOwner.get(cycleEntity), wandererEntity);
    assertEq(CompletedWheelCount.get(wandererEntity, wheelEntity), 0);
    assertEq(CompletedCycleHistory.length(wandererEntity), 0);
    assertEq(IdentityCurrent.get(wandererEntity), 0);
    assertEq(IdentityEarnedTotal.get(wandererEntity), 0);
  }

  function testPermSkill() public {
    cycleLearnSkillSystem.learnSkill(cycleEntity, skillEntity);

    _setRequirements(cycleEntity);
    cycleControlSystem.completeCycle(cycleEntity);

    permSkillSystem.permSkill(wandererEntity, skillEntity);
    assertEq(LearnedSkills.length(wandererEntity), 1, "a");
    assertEq(LearnedSkills.getItem(wandererEntity, 0), skillEntity, "b");

    bytes32 newCycleEntity = cycleControlSystem.startCycle(wandererEntity, guiseEntity, wheelEntity);
    assertNotEq(newCycleEntity, bytes32(0), "c");
    assertNotEq(newCycleEntity, cycleEntity, "d");
    assertEq(newCycleEntity, ActiveCycle.get(wandererEntity), "e");
    assertEq(CycleOwner.get(newCycleEntity), wandererEntity, "f");

    assertEq(LearnedSkills.length(newCycleEntity), 1, "g");
    assertEq(LearnedSkills.getItem(newCycleEntity, 0), skillEntity, "h");
  }
}
