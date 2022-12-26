// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { getGuiseProtoEntity } from "../../guise/GuisePrototypeComponent.sol";
import { LibCycleTurns } from "../LibCycleTurns.sol";

contract CycleTest is BaseTest {
  // taken from InitGuiseSystem, initialized by LibDeploy
  uint256 warriorGuiseProtoEntity = getGuiseProtoEntity("Warrior");

  function setUp() public virtual override {
    super.setUp();
  }

  function testWandererSpawn() public {
    vm.prank(alice);
    uint256 wandererEntity = wandererSpawnSystem.executeTyped(warriorGuiseProtoEntity);
    assertEq(wNFTSubsystem.ownerOf(wandererEntity), alice);
  }

  function testCycleClaimTurns() public {
    vm.prank(alice);
    // spawn should autoclaim the first turns batch
    uint256 wandererEntity = wandererSpawnSystem.executeTyped(warriorGuiseProtoEntity);
    uint256 cycleEntity = activeCycleComponent.getValue(wandererEntity);
    uint256 turns = cycleTurnsComponent.getValue(cycleEntity);
    assertEq(turns, LibCycleTurns.TURNS_PER_PERIOD);
    // trying to claim more should do nothing
    LibCycleTurns.claimTurns(world.components(), cycleEntity);
    turns = cycleTurnsComponent.getValue(cycleEntity);
    assertEq(turns, LibCycleTurns.TURNS_PER_PERIOD);
    // after waiting for ACC_PERIOD, another batch should be claimable
    vm.warp(block.timestamp + LibCycleTurns.ACC_PERIOD);
    LibCycleTurns.claimTurns(world.components(), cycleEntity);
    turns = cycleTurnsComponent.getValue(cycleEntity);
    assertEq(turns, 2 * LibCycleTurns.TURNS_PER_PERIOD);
  }

  // TODO test reverts and edge cases
}