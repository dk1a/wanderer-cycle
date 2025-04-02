// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { Wanderer, GuisePrototype } from "../codegen/index.sol";

import { LibWheel } from "../../wheel/LibWheel.sol";
import { LibCycle } from "../cycle/LibCycle.sol";
import { ERC721Namespaces } from "../token/ERC721Namespaces.sol";

/// @title Spawn a wandererEntity and start a cycle for it.
/// @dev This is for new players, whereas StartCycle is for existing ones.
contract WandererSpawnSystem is System {
  error WandererSpawn_InvalidGuise();

  /// @notice Anyone can freely spawn wanderers, a wanderer is a tokenized game account
  function spawnWanderer(bytes32 guiseEntity) public returns (bytes32 wandererEntity, bytes32 cycleEntity) {
    // Mint nft
    wandererEntity = getUniqueEntity();
    ERC721Namespaces.WandererNFT.mint(_msgSender(), wandererEntity);

    // Flag the entity as wanderer
    Wanderer.set(wandererEntity, true);

    // Get the wheel to use by default (see LibInitWheel)
    bytes32 defaultWheelEntity = LibWheel.getWheelEntity("Wheel of Attainment");

    // Init cycle
    cycleEntity = LibCycle.initCycle(wandererEntity, guiseEntity, defaultWheelEntity);
  }
}
