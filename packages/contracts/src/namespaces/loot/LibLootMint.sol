// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { effectTemplateSystem, EffectTemplateData } from "../effect/codegen/systems/EffectTemplateSystemLib.sol";
import { affixSystem, AffixAvailabilityTargetId, AffixPartId } from "../affix/codegen/systems/AffixSystemLib.sol";

import { Affix, AffixData } from "../affix/codegen/tables/Affix.sol";
import { LootAffixes } from "./codegen/tables/LootAffixes.sol";
import { LootIlvl } from "./codegen/tables/LootIlvl.sol";
import { LootTargetId } from "./codegen/tables/LootTargetId.sol";

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
    bytes32[] memory affixEntities = affixSystem.instantiateRandomAffixes(
      affixPartIds,
      excludeAffixes,
      affixAvailabilityTargetId,
      ilvl,
      randomness
    );
    // Mint picked affixes
    lootMint(lootEntity, affixAvailabilityTargetId, ilvl, affixEntities);
  }

  function lootMint(
    bytes32 lootEntity,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    uint32 ilvl,
    bytes32[] memory affixEntities
  ) internal {
    // Save loot-specific data
    LootTargetId.set(lootEntity, affixAvailabilityTargetId);
    LootAffixes.set(lootEntity, affixEntities);
    LootIlvl.set(lootEntity, ilvl);
    // Save loot as an effect prototype (the effect triggers on-equip)
    effectTemplateSystem.createEffectTemplateFromAffixes(lootEntity, affixEntities);
  }
}
