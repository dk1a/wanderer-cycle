// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { LibCycle } from "./LibCycle.sol";

// import { LibToken } from "../token/LibToken.sol";

/// @title Start a cycle.
/// @dev Very much like WandererSpawnSystem, but for an existing wandererEntity.
contract StartCycleSystem is System {
  function startCycle(
    bytes32 wandererEntity,
    bytes32 guiseProtoEntity,
    bytes32 wheelEntity
  ) public returns (bytes32 cycleEntity) {
    // reverts if sender doesn't have permission
    // LibToken.requireOwner(wandererEntity, msg.sender);
    // init cycle (reverts if a cycle is already active)
    cycleEntity = LibCycle.initCycle(wandererEntity, guiseProtoEntity, wheelEntity);
  }
}
