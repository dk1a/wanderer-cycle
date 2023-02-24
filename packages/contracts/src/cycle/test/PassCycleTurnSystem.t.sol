// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { getGuiseProtoEntity } from "../../guise/GuisePrototypeComponent.sol";
import { LibCycle } from "../LibCycle.sol";
import { LibCycleTurns } from "../LibCycleTurns.sol";

contract PassCycleTurnSystemTest is BaseTest {
  // taken from InitGuiseSystem, initialized by LibDeploy
  uint256 warriorGuiseProtoEntity = getGuiseProtoEntity("Warrior");

  uint256 wandererEntity;
  uint256 cycleEntity;

  function setUp() public virtual override {
    super.setUp();

    vm.prank(alice);
    wandererEntity = wandererSpawnSystem.executeTyped(warriorGuiseProtoEntity);
    cycleEntity = activeCycleComponent.getValue(wandererEntity);
  }

  function test_passTurn() public {
    vm.startPrank(alice);
    uint256 turns = cycleTurnsComponent.getValue(cycleEntity);
    passCycleTurnSystem.executeTyped(wandererEntity);
    uint256 decrementedTurns = cycleTurnsComponent.getValue(cycleEntity);
    assertEq(decrementedTurns, turns - 1);
  }

  function test_passAllTurns() public {
    vm.startPrank(alice);
    uint256 turns = cycleTurnsComponent.getValue(cycleEntity);
    for (uint256 i; i < turns; i++) {
      passCycleTurnSystem.executeTyped(wandererEntity);
    }
    uint256 decrementedTurns = cycleTurnsComponent.getValue(cycleEntity);
    assertEq(decrementedTurns, 0);

    vm.expectRevert(LibCycleTurns.LibCycleTurns__NotEnoughTurns.selector);
    passCycleTurnSystem.executeTyped(wandererEntity);
  }
}
