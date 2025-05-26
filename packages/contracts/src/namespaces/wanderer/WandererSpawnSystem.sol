// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Wanderer } from "./codegen/tables/Wanderer.sol";
import { GuisePrototype } from "../root/codegen/tables/GuisePrototype.sol";

import { initCycleSystem } from "../cycle/codegen/systems/InitCycleSystemLib.sol";

import { LibSOFClass } from "../common/LibSOFClass.sol";
import { LibWheel } from "../wheel/LibWheel.sol";
import { ERC721Namespaces } from "../erc721-puppet/ERC721Namespaces.sol";

/// @title Spawn a wandererEntity and start a cycle for it.
/// @dev This is for new players, whereas StartCycle is for existing ones.
contract WandererSpawnSystem is System {
  error WandererSpawn_InvalidGuise();

  /// @notice Anyone can freely spawn wanderers, a wanderer is a tokenized game account
  function spawnWanderer(bytes32 guiseEntity) public returns (bytes32 wandererEntity, bytes32 cycleEntity) {
    // Mint nft
    wandererEntity = LibSOFClass.instantiate("wanderer");
    uint256 tokenId = uint256(wandererEntity);
    ERC721Namespaces.Wanderer.tokenContract().mint(_msgSender(), tokenId);

    // Flag the entity as wanderer
    Wanderer.set(wandererEntity, true);

    // Get the wheel to use by default (see LibInitWheel)
    bytes32 defaultWheelEntity = LibWheel.getWheelEntity("Wheel of Attainment");

    // Init cycle
    cycleEntity = initCycleSystem.initCycle(wandererEntity, guiseEntity, defaultWheelEntity);
  }
}
