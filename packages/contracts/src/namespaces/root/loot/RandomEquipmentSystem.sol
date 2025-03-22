// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { AffixAvailabilityTargetId } from "../../affix/types.sol";

import { EquipmentTypeComponent } from "../codegen/tables/EquipmentTypeComponent.sol";
import { EquipmentType } from "../equipment/EquipmentType.sol";

import { LibLootEquipment } from "./LibLootEquipment.sol";
import { LibLootMint } from "./LibLootMint.sol";

/**
 * @title Mint a random equippable loot entity.
 */
contract RandomEquipmentSystem is System {
  /**
   * @param ilvl higher ilvl increases the pool of affixes for random generation (higher is better).
   * @param randomness used to randomly pick equipment prototype and affixes.
   * @return lootEntity a new entity.
   */
  function mintRandomEquipmentEntity(uint32 ilvl, uint256 randomness) public returns (bytes32 lootEntity) {
    // Pick equipment type
    (AffixAvailabilityTargetId affixAvailabilityTargetId, EquipmentType equipmentType) = LibLootEquipment
      .pickEquipmentTargetAndType(ilvl, randomness);
    // Get a new unique entity
    lootEntity = getUniqueEntity();
    // Make random loot (affixes and effect)
    LibLootMint.randomLootMint(
      LibLootEquipment.getAffixPartIds(ilvl),
      lootEntity,
      affixAvailabilityTargetId,
      ilvl,
      randomness
    );
    // Set loot's equipment prototype (to make it equippable)
    EquipmentTypeComponent.set(lootEntity, equipmentType);
  }
}
