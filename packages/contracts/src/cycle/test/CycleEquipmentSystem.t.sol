// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { getGuiseProtoEntity } from "../../guise/GuisePrototypeComponent.sol";

// TODO base test for cycle things?
contract CycleEquipmentSystemTest is BaseTest {
  // taken from InitGuiseSystem, initialized by LibDeploy
  uint256 warriorGuiseProtoEntity = getGuiseProtoEntity("Warrior");

  uint256 wandererEntity;
  uint256 cycleEntity;

  function setUp() public virtual override {
    super.setUp();

    vm.prank(alice);
    wandererEntity = wandererSpawnSystem.executeTyped(warriorGuiseProtoEntity);
    cycleEntity = activeCycleComponent.getValue(wandererEntity);

    // TODO this (just permission tests, the base logic should is tested in EquipmentSubsystemTest)
  }
}
