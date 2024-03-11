// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Loot, EffectTemplate, EffectTemplateData } from "../codegen/index.sol";

import { LibPickAffixes } from "../affix/LibPickAffixes.sol";
import { LibEffectTemplate } from "../modules/effect/LibEffectTemplate.sol";

library LibLootMint {
  function randomLootMint(
    IUint256Component components,
    AffixPartId[] memory affixPartIds,
    uint256 lootEntity,
    uint256 targetEntity,
    uint32 ilvl,
    uint256 randomness
  ) internal {
    uint256[] memory excludeAffixes;
    randomLootMint(components, affixPartIds, excludeAffixes, lootEntity, targetEntity, ilvl, randomness);
  }

  function randomLootMint(
    AffixPartId[] memory affixPartIds,
    bytes32 lootEntity,
    bytes32 targetEntity,
    uint32 ilvl,
    uint256 randomness
  ) internal {
    // pick affixes
    (
      bytes32[] memory statmodProtoEntities,
      bytes32[] memory affixProtoEntities,
      uint32[] memory affixValues
    ) = LibPickAffixes.pickAffixes(affixPartIds, targetEntity, ilvl, randomness);
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
    // save loot-specific data
    lootComp.set(
      lootEntity,
      Loot({ ilvl: ilvl, affixPartIds: affixPartIds, affixProtoEntities: affixProtoEntities, affixValues: affixValues })
    );
    // save loot as an effect prototype (the effect triggers on-equip)
    LibEffectTemplate.verifiedSet(
      lootEntity,
      EffectTemplate({ statmodProtoEntities: statmodProtoEntities, statmodValues: affixValues })
    );
  }
}
