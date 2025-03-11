// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { LibEffectTemplate, EffectTemplateData } from "../../effect/LibEffectTemplate.sol";
import { AffixAvailabilityTargetId, AffixPartId, LibPickAffix, Affix, AffixData } from "../../affix/LibPickAffix.sol";

import { LootAffixes, LootIlvl } from "../codegen/index.sol";

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
    // pick affixes
    (
      bytes32[] memory statmodProtoEntities,
      bytes32[] memory affixProtoEntities,
      uint32[] memory affixValues
    ) = LibPickAffix.pickAffixes(affixPartIds, excludeAffixes, affixAvailabilityTargetId, ilvl, randomness);
    // mint picked affixes
    lootMint(lootEntity, ilvl, affixPartIds, statmodProtoEntities, affixProtoEntities, affixValues);
  }

  function lootMint(
    bytes32 lootEntity,
    uint32 ilvl,
    AffixPartId[] memory affixPartIds,
    bytes32[] memory statmodProtoEntities,
    bytes32[] memory affixProtoEntities,
    uint32[] memory affixValues
  ) internal {
    bytes32[] memory affixEntities = new bytes32[](affixPartIds.length);
    for (uint256 i; i < affixPartIds.length; i++) {
      bytes32 affixEntity = getUniqueEntity();
      Affix.set(affixEntity, affixProtoEntities[i], affixPartIds[i], affixValues[i]);
      affixEntities[i] = affixEntity;
    }
    // save loot-specific data
    LootAffixes.set(lootEntity, affixEntities);
    LootIlvl.set(lootEntity, ilvl);
    // save loot as an effect prototype (the effect triggers on-equip)
    LibEffectTemplate.verifiedSet(
      lootEntity,
      EffectTemplateData({ entities: statmodProtoEntities, values: affixValues })
    );
  }
}
