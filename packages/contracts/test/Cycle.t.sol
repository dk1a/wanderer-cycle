// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { BaseTest } from "./BaseTest.t.sol";

import { cycleControlSystem } from "../src/namespaces/cycle/codegen/systems/CycleControlSystemLib.sol";
import { LibGuise } from "../src/namespaces/root/guise/LibGuise.sol";
import { LibCycle } from "../src/namespaces/cycle/LibCycle.sol";
import { LibCycleTurns } from "../src/namespaces/cycle/LibCycleTurns.sol";
import { ActiveCycle, CycleOwner } from "../src/namespaces/cycle/codegen/index.sol";
import { ActiveWheel, CompletedWheels, IdentityCurrent, IdentityEarnedTotal } from "../src/namespaces/wheel/codegen/index.sol";
import { IDENTITY_INCREMENT } from "../src/namespaces/wheel/constants.sol";

contract CycleTest is BaseTest {
  bytes32 internal guiseEntity;
  bytes32 internal wandererEntity;
  bytes32 internal cycleEntity;
  bytes32 internal wheelEntity;

  function setUp() public virtual override {
    super.setUp();

    guiseEntity = LibGuise.getGuiseEntity("Warrior");
    (wandererEntity, cycleEntity) = world.spawnWanderer(guiseEntity);

    wheelEntity = ActiveWheel.getWheelEntity(cycleEntity);
  }

  function testSetUp() public view {
    assertNotEq(wheelEntity, bytes32(0));
    assertEq(ActiveCycle.get(wandererEntity), cycleEntity);
    assertEq(CycleOwner.get(cycleEntity), wandererEntity);
  }

  function testCompleteCycle() public {
    cycleControlSystem.completeCycle(cycleEntity);

    assertEq(ActiveCycle.get(wandererEntity), bytes32(0));
    assertEq(CycleOwner.get(cycleEntity), wandererEntity);
    assertEq(CompletedWheels.length(wandererEntity, wheelEntity), 1);
    assertEq(CompletedWheels.getItem(wandererEntity, wheelEntity, 0), cycleEntity);
    assertEq(IdentityCurrent.get(wandererEntity), IDENTITY_INCREMENT);
    assertEq(IdentityEarnedTotal.get(wandererEntity), IDENTITY_INCREMENT);
  }

  function testCancelCycle() public {
    cycleControlSystem.cancelCycle(cycleEntity);

    assertEq(ActiveCycle.get(wandererEntity), bytes32(0));
    assertEq(CycleOwner.get(cycleEntity), wandererEntity);
    assertEq(CompletedWheels.length(wandererEntity, wheelEntity), 0);
    assertEq(IdentityCurrent.get(wandererEntity), 0);
    assertEq(IdentityEarnedTotal.get(wandererEntity), 0);
  }

  /* TODO test proper ending+starting a cycle, this isn't WandererSpawn and cannot start a cycle from nothing
  function testStartCycle() public {
    cycleEntity = world.startCycle(wandererEntity, guiseEntity, wheelEntity);

    assertEq(cycleEntity, ActiveCycle.get(wandererEntity));
  }
  */
}
