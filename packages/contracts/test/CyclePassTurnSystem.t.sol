// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { BaseTest } from "./BaseTest.t.sol";
import { CycleTurns } from "../src/namespaces/cycle/codegen/index.sol";

import { cyclePassTurnSystem } from "../src/namespaces/cycle/codegen/systems/CyclePassTurnSystemLib.sol";
import { LibGuise } from "../src/namespaces/root/guise/LibGuise.sol";
import { LibCycle } from "../src/namespaces/cycle/LibCycle.sol";
import { LibCycleTurns } from "../src/namespaces/cycle/LibCycleTurns.sol";

contract CyclePassTurnSystemTest is BaseTest {
  bytes32 internal guiseEntity;
  bytes32 internal cycleEntity;

  function setUp() public virtual override {
    super.setUp();

    guiseEntity = LibGuise.getGuiseEntity("Warrior");
    vm.prank(alice);
    (, cycleEntity) = world.spawnWanderer(guiseEntity);
  }

  function testPassTurn() public {
    vm.prank(alice);
    cyclePassTurnSystem.passTurn(cycleEntity);

    uint32 turns = CycleTurns.get(cycleEntity);
    assertEq(turns, LibCycleTurns.TURNS_PER_PERIOD - 1);
  }

  function testPassAllTurns() public {
    // Pass all available turns
    for (uint i = 0; i < LibCycleTurns.TURNS_PER_PERIOD; i++) {
      vm.prank(alice);
      cyclePassTurnSystem.passTurn(cycleEntity);
    }

    uint32 turns = CycleTurns.get(cycleEntity);
    assertEq(turns, 0, "All turns should be used up");
  }
}
