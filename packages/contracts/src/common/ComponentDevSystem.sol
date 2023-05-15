// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { ComponentDevSystem as _ComponentDevSystem } from "std-contracts/systems/ComponentDevSystem.sol";

uint256 constant ID = uint256(keccak256("system.ComponentDev"));

contract ComponentDevSystem is _ComponentDevSystem {
  constructor(IWorld _world, address _components) _ComponentDevSystem(_world, _components) {}
}
