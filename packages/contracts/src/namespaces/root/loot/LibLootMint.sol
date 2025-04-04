// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { LibEffectTemplate, EffectTemplateData } from "../../effect/LibEffectTemplate.sol";
import { AffixAvailabilityTargetId, AffixPartId, LibPickAffix, Affix, AffixData } from "../../affix/LibPickAffix.sol";

import { LootAffixes } from "../codegen/tables/LootAffixes.sol";
import { LootIlvl } from "../codegen/tables/LootIlvl.sol";
import { LootTargetId } from "../codegen/tables/LootTargetId.sol";

library LibLootMint {
  function randomLootMint(
    AffixPartId[] memory affixPartIds,
    bytes32 lootEntity,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    uint32 ilvl,
    uint256 randomness
  ) internal {
    bytes32[] memory excludeAffixes;
    randomLootMint(affixPartIds, excludeAffixes, lootEntity, affixAvailabilityTargetId, ilvl, randomness);
  }

  function randomLootMint(
    AffixPartId[] memory affixPartIds,
    bytes32[] memory excludeAffixes,
    bytes32 lootEntity,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    uint32 ilvl,
    uint256 randomness
  ) internal {
    // Pick affixes
    (bytes32[] memory statmodEntities, bytes32[] memory affixProtoEntities, uint32[] memory affixValues) = LibPickAffix
      .pickAffixes(affixPartIds, excludeAffixes, affixAvailabilityTargetId, ilvl, randomness);
    // Mint picked affixes
    lootMint(
      lootEntity,
      affixAvailabilityTargetId,
      ilvl,
      affixPartIds,
      statmodEntities,
      affixProtoEntities,
      affixValues
    );
  }

  function lootMint(
    bytes32 lootEntity,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    uint32 ilvl,
    AffixPartId[] memory affixPartIds,
    bytes32[] memory statmodEntities,
    bytes32[] memory affixProtoEntities,
    uint32[] memory affixValues
  ) internal {
    bytes32[] memory affixEntities = new bytes32[](affixPartIds.length);
    LootTargetId.set(lootEntity, affixAvailabilityTargetId);
    for (uint256 i; i < affixPartIds.length; i++) {
      bytes32 affixEntity = getUniqueEntity();
      Affix.set(affixEntity, affixProtoEntities[i], affixPartIds[i], affixValues[i]);
      affixEntities[i] = affixEntity;
    }
    // Save loot-specific data
    LootAffixes.set(lootEntity, affixEntities);
    LootIlvl.set(lootEntity, ilvl);
    // Save loot as an effect prototype (the effect triggers on-equip)
    LibEffectTemplate.verifiedSet(
      lootEntity,
      EffectTemplateData({ statmodEntities: statmodEntities, values: affixValues })
    );
  }
}
