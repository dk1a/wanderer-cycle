// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { getGuiseProtoEntity } from "../../guise/GuisePrototypeComponent.sol";

contract WandererSpawnSystemTest is BaseTest {
  // taken from InitGuiseSystem, initialized by LibDeploy
  uint256 warriorGuiseProtoEntity = getGuiseProtoEntity("Warrior");

  function setUp() public virtual override {
    super.setUp();
  }

  function testSpawn() public {
    vm.prank(alice);
    uint256 wandererEntity = wandererSpawnSystem.executeTyped(warriorGuiseProtoEntity);
    assertEq(wNFTSubsystem.ownerOf(wandererEntity), alice);
  }
}