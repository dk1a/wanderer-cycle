// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { ReverseHashNameSystem, ID as ReverseHashNameSystemID } from "../common/ReverseHashNameSystem.sol";

uint256 constant ID = uint256(keccak256("system.InitReverseHashName"));

contract InitReverseHashNameSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory) public override onlyOwner returns (bytes memory) {
    ReverseHashNameSystem system = ReverseHashNameSystem(getAddressById(world.systems(), ReverseHashNameSystemID));

    system.executeTyped("strength");
    system.executeTyped("arcana");
    system.executeTyped("dexterity");
    system.executeTyped("life");
    system.executeTyped("mana");
    system.executeTyped("fortune");
    system.executeTyped("connection");
    system.executeTyped("life gained per turn");
    system.executeTyped("mana gained per turn");
    system.executeTyped("attack");
    system.executeTyped("spell");
    system.executeTyped("resistance");
    system.executeTyped("damage taken per round");
    system.executeTyped("damage taken");
    system.executeTyped("reduced damage done");
    system.executeTyped("rounds stunned");
    system.executeTyped("% of missing life to {element} attack");
    system.executeTyped("level");

    return '';
  }
}