// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { getGuiseProtoEntity } from "../../guise/GuisePrototypeComponent.sol";
import { LibCycle } from "../LibCycle.sol";

contract StartCycleSystemTest is BaseTest {
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

  function test_startCycle_cycleIsAlreadyActive() public {
    vm.prank(alice);
    vm.expectRevert(LibCycle.LibCycle__CycleIsAlreadyActive.selector);
    startCycleSystem.executeTyped(
      wandererEntity,
      warriorGuiseProtoEntity
    );
  }

  // TODO this is a stub, requires endCycle etc for proper tests
}