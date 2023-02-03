// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { getGuiseProtoEntity } from "../../guise/GuisePrototypeComponent.sol";
import { LibCycleTurns } from "../LibCycleTurns.sol";

contract LibCycleTurnsTest is BaseTest {
  // taken from InitGuiseSystem, initialized by LibDeploy
  uint256 warriorGuiseProtoEntity = getGuiseProtoEntity("Warrior");

  uint256 cycleEntity;
  uint256 initialTurns;

  function setUp() public virtual override {
    super.setUp();

    vm.prank(alice);
    uint256 wandererEntity = wandererSpawnSystem.executeTyped(warriorGuiseProtoEntity);
    cycleEntity = activeCycleComponent.getValue(wandererEntity);
    initialTurns = cycleTurnsComponent.getValue(cycleEntity);
  }

  function test_setUp() public {
    // spawn should autoclaim the first turns batch
    assertEq(initialTurns, LibCycleTurns.TURNS_PER_PERIOD);
  }

  function test_claimTurns_premature() public {
    LibCycleTurns.claimTurns(components, cycleEntity);
    // trying to claim again prematurely should do nothing
    LibCycleTurns.claimTurns(components, cycleEntity);

    uint256 turns = cycleTurnsComponent.getValue(cycleEntity);
    assertEq(turns, initialTurns);
  }

  function test_claimTurns_secondPeriod() public {
    // after waiting for ACC_PERIOD, another batch should be claimable
    vm.warp(block.timestamp + LibCycleTurns.ACC_PERIOD);
    LibCycleTurns.claimTurns(components, cycleEntity);
    uint256 turns = cycleTurnsComponent.getValue(cycleEntity);
    assertEq(turns, initialTurns + LibCycleTurns.TURNS_PER_PERIOD);
  }

  function test_claimTurns_twoPeriods() public {
    // after waiting for 2 ACC_PERIODs, 2 batches should be claimable at once
    vm.warp(block.timestamp + 2 * LibCycleTurns.ACC_PERIOD);
    LibCycleTurns.claimTurns(components, cycleEntity);
    uint256 turns = cycleTurnsComponent.getValue(cycleEntity);
    assertEq(turns, initialTurns + 2 * LibCycleTurns.TURNS_PER_PERIOD);
  }

  function test_claimTurns_atMaxCurrent() public {
    vm.warp(block.timestamp + LibCycleTurns.ACC_PERIOD);

    uint32 maxCurrent = LibCycleTurns.MAX_CURRENT_TURNS_FOR_CLAIM;
    cycleTurnsComponent.set(cycleEntity, maxCurrent);
    // claim turns while at max, this should succeed
    LibCycleTurns.claimTurns(components, cycleEntity);
    uint256 turns = cycleTurnsComponent.getValue(cycleEntity);
    assertEq(turns, maxCurrent + LibCycleTurns.TURNS_PER_PERIOD);
  }

  function test_claimTurns_overMaxCurrent() public {
    vm.warp(block.timestamp + LibCycleTurns.ACC_PERIOD);

    uint32 maxCurrent = LibCycleTurns.MAX_CURRENT_TURNS_FOR_CLAIM;
    cycleTurnsComponent.set(cycleEntity, maxCurrent + 1);
    // claim turns while over max, this should do nothing (same as premature)
    LibCycleTurns.claimTurns(components, cycleEntity);
    uint256 turns = cycleTurnsComponent.getValue(cycleEntity);
    assertEq(turns, maxCurrent + 1);

    // reduce current turns to max
    cycleTurnsComponent.set(cycleEntity, LibCycleTurns.MAX_CURRENT_TURNS_FOR_CLAIM);
    // this should succeed (ensuring that the previous empty claim didn't remove potential claimable turns)
    LibCycleTurns.claimTurns(components, cycleEntity);
    turns = cycleTurnsComponent.getValue(cycleEntity);
    assertEq(turns, maxCurrent + LibCycleTurns.TURNS_PER_PERIOD);
  }
}