// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { ActiveCycle } from "../src/codegen/index.sol";

import { LibGuise } from "../src/guise/LibGuise.sol";

contract StartCycleSystemTest is MudLibTest {
  bytes32 internal guiseEntity;
  bytes32 internal wandererEntity;
  bytes32 internal cycleEntity;

  function setUp() public virtual override {
    super.setUp();

    guiseEntity = LibGuise.getGuiseEntity("Warrior");
    (wandererEntity, cycleEntity) = world.spawnWanderer(guiseEntity);
  }

  /* TODO test proper ending+starting a cycle, this isn't WandererSpawn and cannot start a cycle from nothing
  function testStartCycle() public {
    cycleEntity = world.startCycle(wandererEntity, guiseEntity, wheelEntity);

    assertEq(cycleEntity, ActiveCycle.get(wandererEntity));
  }
  */
}
