// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { AffixAvailabilityTargetId } from "../affix/types.sol";

import { MapTypeComponent } from "../map/codegen/tables/MapTypeComponent.sol";
import { MapType } from "../map/MapType.sol";

import { LibLootEquipment } from "./LibLootEquipment.sol";
import { LibLootMint } from "./LibLootMint.sol";
import { LibLootMap } from "./LibLootMap.sol";

/**
 * @title Mint a random map entity.
 */
contract RandomMapSystem is System {
  /**
   * @param ilvl higher ilvl increases the pool of affixes for random generation (higher is better).
   * @param affixAvailabilityTargetId semi-hardcoded ids used to group available affixes.
   * @param mapType map type.
   * @param randomness used to randomly pick equipment prototype and affixes.
   * @return lootEntity a new entity.
   */
  function mintRandomMapEntity(
    uint32 ilvl,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    MapType mapType,
    uint256 randomness
  ) internal returns (bytes32 lootEntity) {
    // Get a new unique entity
    lootEntity = getUniqueEntity();
    // Make random loot (affixes and effect)
    LibLootMint.randomLootMint(
      LibLootMap.getAffixPartIds(ilvl),
      lootEntity,
      affixAvailabilityTargetId,
      ilvl,
      randomness
    );
    // Mark this loot as a map by setting its MapType
    MapTypeComponent.set(lootEntity, mapType);
  }
}
