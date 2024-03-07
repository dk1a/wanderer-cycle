// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { DefaultWheel, Wanderer, GuisePrototype } from "../codegen/index.sol";

import { LibCycle } from "../cycle/LibCycle.sol";

/// @title Spawn a wandererEntity and start a cycle for it.
/// @dev This is for new players, whereas StartCycle is for existing ones.
contract WandererSpawnSystem is System {
  error WandererSpawn_InvalidGuise();

  /// @notice Anyone can freely spawn wanderers, a wanderer is a tokenized game account
  function spawnWanderer(bytes32 guiseEntity) public returns (bytes32 wandererEntity, bytes32 cycleEntity) {
    // mint nft
    wandererEntity = getUniqueEntity();
    // wnftSystem.executeSafeMint(msg.sender, wandererEntity, "");

    // flag the entity as wanderer
    Wanderer.set(wandererEntity, true);

    bytes32 defaultWheelEntity = DefaultWheel.get();

    // init cycle
    cycleEntity = LibCycle.initCycle(wandererEntity, guiseEntity, defaultWheelEntity);
  }
}
