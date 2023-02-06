// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibCycle } from "./LibCycle.sol";
import { LibToken } from "../token/LibToken.sol";

uint256 constant ID = uint256(keccak256("system.StartCycle"));

/// @title Start a cycle.
/// @dev Very much like WandererSpawnSystem, but for an existing wandererEntity.
contract StartCycleSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(uint256 wandererEntity, uint256 guiseProtoEntity) public returns (uint256 cycleEntity) {
    return abi.decode(execute(abi.encode(wandererEntity, guiseProtoEntity)), (uint256));
  }

  function execute(bytes memory args) public override returns (bytes memory) {
    (uint256 wandererEntity, uint256 guiseProtoEntity) = abi.decode(args, (uint256, uint256));

    // reverts if sender doesn't have permission
    LibToken.requireOwner(components, wandererEntity, msg.sender);
    // init cycle (reverts if a cycle is already active)
    uint256 cycleEntity = LibCycle.initCycle(world, wandererEntity, guiseProtoEntity);

    return abi.encode(cycleEntity);
  }
}
