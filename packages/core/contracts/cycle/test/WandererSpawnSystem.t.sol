// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Test } from "../../Test.sol";

import { World } from "@latticexyz/solecs/src/World.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { WandererSpawnSystem, ID as WandererSpawnSystemID } from "../WandererSpawnSystem.sol";
import { WNFTSystem, ID as WNFTSystemID } from "../../token/WNFTSystem.sol";

contract WandererSpawnSystemTest is Test {

  address alice = address(bytes20(keccak256('alice')));
  address bob = address(bytes20(keccak256('bob')));

  // taken from LibInitGuise, initialized by LibDeploy
  uint256 warriorGuiseProtoEntity = uint256(keccak256("Warrior"));

  WandererSpawnSystem wSpawnSystem;
  WNFTSystem wnftSystem;

  function setUp() public virtual override {
    super.setUp();

    wSpawnSystem = WandererSpawnSystem(getAddressById(world.systems(), WandererSpawnSystemID));
    wnftSystem = WNFTSystem(getAddressById(world.systems(), WNFTSystemID));
  }

  function testSpawn() public {
    vm.prank(alice);
    uint256 wandererEntity = wSpawnSystem.executeTyped(warriorGuiseProtoEntity);
    assertEq(wnftSystem.ownerOf(wandererEntity), alice);
  }
}