// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";

import { LibGuise } from "../src/namespaces/root/guise/LibGuise.sol";
import { LibCycle } from "../src/namespaces/root/cycle/LibCycle.sol";
import { LibCycleTurns } from "../src/namespaces/root/cycle/LibCycleTurns.sol";
import { LibWheel } from "../src/namespaces/wheel/LibWheel.sol";
import { ActiveCycle } from "../src/namespaces/root/codegen/index.sol";
import { ActiveWheel, WheelsCompleted, IdentityCurrent, IdentityEarnedTotal } from "../src/namespaces/wheel/codegen/index.sol";

contract CycleTest is MudLibTest {
  bytes32 internal guiseEntity;
  bytes32 internal wandererEntity;
  bytes32 internal cycleEntity;
  bytes32 internal wheelEntity;

  function setUp() public virtual override {
    super.setUp();

    guiseEntity = LibGuise.getGuiseEntity("Warrior");
    (wandererEntity, cycleEntity) = world.spawnWanderer(guiseEntity);

    wheelEntity = ActiveWheel.get(cycleEntity);
  }

  function testCompleteCycle() public {
    assertNotEq(wheelEntity, bytes32(0));
    assertEq(ActiveCycle.get(wandererEntity), cycleEntity);
    world.completeCycle(wandererEntity);

    assertEq(ActiveCycle.get(wandererEntity), bytes32(0));
    assertEq(WheelsCompleted.get(wandererEntity, wheelEntity), 1);
    assertEq(IdentityCurrent.get(wandererEntity), LibWheel.IDENTITY_INCREMENT);
    assertEq(IdentityEarnedTotal.get(wandererEntity), LibWheel.IDENTITY_INCREMENT);
  }

  /* TODO test proper ending+starting a cycle, this isn't WandererSpawn and cannot start a cycle from nothing
  function testStartCycle() public {
    cycleEntity = world.startCycle(wandererEntity, guiseEntity, wheelEntity);

    assertEq(cycleEntity, ActiveCycle.get(wandererEntity));
  }
  */
}
