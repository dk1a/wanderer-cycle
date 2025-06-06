// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { effectTemplateSystem, EffectTemplateData } from "../effect/codegen/systems/EffectTemplateSystemLib.sol";
import { affixSystem, AffixAvailabilityTargetId, AffixPartId } from "../affix/codegen/systems/AffixSystemLib.sol";

import { Affix, AffixData } from "../affix/codegen/tables/Affix.sol";
import { LootAffixes } from "./codegen/tables/LootAffixes.sol";
import { LootTier } from "./codegen/tables/LootTier.sol";
import { LootTargetId } from "./codegen/tables/LootTargetId.sol";

library LibLootMint {
  function randomLootMint(
    AffixPartId[] memory affixPartIds,
    bytes32 lootEntity,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    uint32 affixTier,
    uint256 randomness
  ) internal {
    // Pick affixes
    bytes32[] memory affixEntities = affixSystem.instantiateRandomAffixes(
      affixPartIds,
      new bytes32[](0),
      affixAvailabilityTargetId,
      affixTier,
      randomness
    );
    // Mint picked affixes
    lootMint(lootEntity, affixAvailabilityTargetId, affixTier, affixEntities);
  }

  function randomLootMint(
    bytes32[] memory manualAffixes,
    AffixPartId[] memory affixPartIds,
    bytes32 lootEntity,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    uint32 affixTier,
    uint256 randomness
  ) internal {
    // Pick affixes
    bytes32[] memory affixEntities = affixSystem.instantiateRandomAffixes(
      affixPartIds,
      manualAffixes,
      affixAvailabilityTargetId,
      affixTier,
      randomness
    );
    // Merge manual and random affixes
    bytes32[] memory allAffixEntities = new bytes32[](manualAffixes.length + affixEntities.length);
    for (uint256 i = 0; i < manualAffixes.length; i++) {
      allAffixEntities[i] = manualAffixes[i];
    }
    for (uint256 i = 0; i < affixEntities.length; i++) {
      allAffixEntities[manualAffixes.length + i] = affixEntities[i];
    }
    // Mint picked affixes
    lootMint(lootEntity, affixAvailabilityTargetId, affixTier, allAffixEntities);
  }

  function lootMint(
    bytes32 lootEntity,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    uint32 affixTier,
    bytes32[] memory affixEntities
  ) internal {
    // Save loot-specific data
    LootTargetId.set(lootEntity, affixAvailabilityTargetId);
    LootAffixes.set(lootEntity, affixEntities);
    LootTier.set(lootEntity, affixTier);
    // Save loot as an effect prototype (the effect triggers on-equip)
    effectTemplateSystem.setEffectTemplateFromAffixes(lootEntity, affixEntities);
  }
}
