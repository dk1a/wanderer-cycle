// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { CycleTurns } from "../src/codegen/index.sol";

import { LibGuise } from "../src/guise/LibGuise.sol";
import { LibCycle } from "../src/cycle/LibCycle.sol";
import { LibCycleTurns } from "../src/cycle/LibCycleTurns.sol";

contract PassCycleTurnSystemTest is MudLibTest {
  bytes32 internal wandererEntity;
  bytes32 internal guiseProtoEntity;
  bytes32 internal wheelEntity;
  bytes32 internal cycleEntity;

  function setUp() public virtual override {
    super.setUp();
    // Initialize with test data
    wandererEntity = keccak256("wandererEntity");
    wheelEntity = keccak256("wheelEntity");

    guiseProtoEntity = LibGuise.getGuiseEntity("Warrior");

    // Simulate existing cycle entity
    cycleEntity = LibCycle.initCycle(wandererEntity, guiseProtoEntity, wheelEntity);
  }

  function testPassCycle() public {
    world.passCycle(wandererEntity);

    uint32 turns = CycleTurns.get(cycleEntity);
    assertEq(turns, LibCycleTurns.TURNS_PER_PERIOD - 1);
  }

  function testPassAllTurns() public {
    // Pass all available turns
    for (uint i = 0; i < LibCycleTurns.TURNS_PER_PERIOD; i++) {
      world.passCycle(wandererEntity);
    }

    uint32 turns = CycleTurns.get(cycleEntity);
    assertEq(turns, 0, "All turns should be used up");
  }
}
