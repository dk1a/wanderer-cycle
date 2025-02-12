// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { MapTypeComponent } from "../codegen/index.sol";
import { MapType } from "./MapType.sol";

import { LibLootEquipment } from "../loot/LibLootEquipment.sol";
import { LibLootMint } from "../loot/LibLootMint.sol";
import { LibLootMap } from "../loot/LibLootMap.sol";

/// @title Mint a random map entity.
contract RandomMapSystem is System {
  /// @param ilvl higher ilvl increases the pool of affixes for random generation (higher is better).
  /// @param affixAvailabilityEntity used by Affix tables to group available affixes.
  /// @param mapType map type.
  /// @param randomness used to randomly pick equipment prototype and affixes.
  /// @return lootEntity a new entity.
  function mintRandomMapEntity(
    uint32 ilvl,
    bytes32 affixAvailabilityEntity,
    MapType mapType,
    uint256 randomness
  ) internal returns (bytes32 lootEntity) {
    // get a new unique id
    lootEntity = getUniqueEntity();
    // make random loot (affixes and effect)
    LibLootMint.randomLootMint(LibLootMap.getAffixPartIds(ilvl), lootEntity, affixAvailabilityEntity, ilvl, randomness);
    // mark this loot as a map by setting its MapType
    MapTypeComponent.set(lootEntity, mapType);

    return lootEntity;
  }
}
