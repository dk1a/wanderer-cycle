// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibCycleTurns } from "../src/cycle/LibCycleTurns.sol";
import { CycleTurns, CycleTurnsLastClaimed, ActiveGuise, ActiveCycle } from "../src/codegen/index.sol";
import { MudLibTest } from "./MudLibTest.t.sol";

contract LibCycleTurnsTest is MudLibTest {
  bytes32 internal targetEntity = keccak256("targetEntity");
  bytes32 internal cycleEntity = keccak256("cycleEntity");

  uint32 initialTurns;

  function test_setUp() public {
    LibCycleTurns.claimTurns(cycleEntity);

    initialTurns = CycleTurns.get(cycleEntity);
    // spawn should autoclaim the first turns batch
    assertEq(initialTurns, LibCycleTurns.TURNS_PER_PERIOD);
  }

  function test_claimTurns_premature() public {
    LibCycleTurns.claimTurns(cycleEntity);

    initialTurns = CycleTurns.get(cycleEntity);
    // trying to claim again prematurely should do nothing
    LibCycleTurns.claimTurns(cycleEntity);

    uint32 turns = CycleTurns.get(cycleEntity);
    assertEq(turns, initialTurns);
  }

  function test_claimTurns_secondPeriod() public {
    initialTurns = CycleTurns.get(cycleEntity);

    // after waiting for ACC_PERIOD, another batch should be claimable
    vm.warp(block.timestamp + LibCycleTurns.ACC_PERIOD);
    LibCycleTurns.claimTurns(cycleEntity);
    uint32 turns = CycleTurns.get(cycleEntity);
    assertEq(turns, initialTurns + LibCycleTurns.TURNS_PER_PERIOD);
  }

  function test_claimTurns_twoPeriods() public {
    LibCycleTurns.claimTurns(cycleEntity);

    initialTurns = CycleTurns.get(cycleEntity);

    // after waiting for 2 ACC_PERIODs, 2 batches should be claimable at once
    vm.warp(block.timestamp + 2 * LibCycleTurns.ACC_PERIOD);
    LibCycleTurns.claimTurns(cycleEntity);
    uint256 turns = CycleTurns.get(cycleEntity);
    assertEq(turns, initialTurns + 2 * LibCycleTurns.TURNS_PER_PERIOD);
  }

  function test_claimTurns_atMaxCurrent() public {
    vm.warp(block.timestamp + LibCycleTurns.ACC_PERIOD);

    uint32 maxCurrent = LibCycleTurns.MAX_CURRENT_TURNS_FOR_CLAIM;
    CycleTurns.set(cycleEntity, maxCurrent);
    // claim turns while at max, this should succeed
    LibCycleTurns.claimTurns(cycleEntity);
    uint256 turns = CycleTurns.get(cycleEntity);
    assertEq(turns, maxCurrent + LibCycleTurns.TURNS_PER_PERIOD);
  }

  function test_claimTurns_overMaxCurrent() public {
    vm.warp(block.timestamp + LibCycleTurns.ACC_PERIOD);

    uint32 maxCurrent = LibCycleTurns.MAX_CURRENT_TURNS_FOR_CLAIM;
    CycleTurns.set(cycleEntity, maxCurrent + 1);
    // claim turns while over max, this should do nothing (same as premature)
    LibCycleTurns.claimTurns(cycleEntity);
    uint256 turns = CycleTurns.get(cycleEntity);
    assertEq(turns, maxCurrent + 1);

    // reduce current turns to max
    CycleTurns.set(cycleEntity, LibCycleTurns.MAX_CURRENT_TURNS_FOR_CLAIM);
    // this should succeed (ensuring that the previous empty claim didn't remove potential claimable turns)
    LibCycleTurns.claimTurns(cycleEntity);
    turns = CycleTurns.get(cycleEntity);
    assertEq(turns, maxCurrent + LibCycleTurns.TURNS_PER_PERIOD);
  }
}
