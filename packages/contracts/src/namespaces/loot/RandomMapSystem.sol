// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { AffixAvailabilityTargetId } from "../affix/types.sol";

import { MapTypeComponent } from "../map/codegen/tables/MapTypeComponent.sol";
import { MapType } from "../map/MapType.sol";

import { LibSOFClass } from "../common/LibSOFClass.sol";
import { LibLootEquipment } from "./LibLootEquipment.sol";
import { LibLootMint } from "./LibLootMint.sol";
import { LibLootMap } from "./LibLootMap.sol";

/**
 * @title Mint a random map entity.
 */
contract RandomMapSystem is System {
  /**
   * @param affixTier higher tier increases the pool of affixes for random generation.
   * @param affixAvailabilityTargetId semi-hardcoded ids used to group available affixes.
   * @param mapType map type.
   * @param randomness used to randomly pick affixes.
   * @return lootEntity a new entity.
   */
  function mintRandomMapEntity(
    uint32 affixTier,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    MapType mapType,
    uint256 randomness
  ) internal returns (bytes32 lootEntity) {
    // Instantiate map entity
    lootEntity = LibSOFClass.instantiate("map");
    // Make random loot (affixes and effect)
    LibLootMint.randomLootMint(
      LibLootMap.getAffixPartIds(affixTier),
      lootEntity,
      affixAvailabilityTargetId,
      affixTier,
      randomness
    );
    // Mark this loot as a map by setting its MapType
    MapTypeComponent.set(lootEntity, mapType);
  }
}
