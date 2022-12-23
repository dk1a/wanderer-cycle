// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Test } from "../../Test.sol";

import { World } from "@latticexyz/solecs/src/World.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { getGuiseProtoEntity } from "../../guise/GuisePrototypeComponent.sol";
import { WandererSpawnSystem, ID as WandererSpawnSystemID } from "../WandererSpawnSystem.sol";
import { WNFTSubsystem, ID as WNFTSubsystemID } from "../../token/WNFTSubsystem.sol";

contract WandererSpawnSystemTest is Test {

  address alice = address(bytes20(keccak256('alice')));
  address bob = address(bytes20(keccak256('bob')));

  // taken from InitGuiseSystem, initialized by LibDeploy
  uint256 warriorGuiseProtoEntity = getGuiseProtoEntity("Warrior");

  WandererSpawnSystem wSpawnSystem;
  WNFTSubsystem wnftSubsystem;

  function setUp() public virtual override {
    super.setUp();

    wSpawnSystem = WandererSpawnSystem(getAddressById(world.systems(), WandererSpawnSystemID));
    wnftSubsystem = WNFTSubsystem(getAddressById(world.systems(), WNFTSubsystemID));
  }

  function testSpawn() public {
    vm.prank(alice);
    uint256 wandererEntity = wSpawnSystem.executeTyped(warriorGuiseProtoEntity);
    assertEq(wnftSubsystem.ownerOf(wandererEntity), alice);
  }
}