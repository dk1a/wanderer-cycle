// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibPickAffixes, AffixPartId } from "../affix/LibPickAffixes.sol";

import { Loot, LootComponent, ID as LootComponentID } from "./LootComponent.sol";
import { EffectRemovability, EffectPrototype, LibEffectPrototype } from "../effect/LibEffectPrototype.sol";

library LibLootMint {
  function randomLootMint(
    IUint256Component components,
    AffixPartId[] memory affixPartIds,
    uint256 lootEntity,
    uint256 targetEntity,
    uint256 ilvl,
    uint256 randomness
  ) internal {
    uint256[] memory excludeAffixes;
    randomLootMint(
      components,
      affixPartIds,
      excludeAffixes,
      lootEntity,
      targetEntity,
      ilvl,
      randomness
    );
  }

  function randomLootMint(
    IUint256Component components,
    AffixPartId[] memory affixPartIds,
    uint256[] memory excludeAffixes,
    uint256 lootEntity,
    uint256 targetEntity,
    uint256 ilvl,
    uint256 randomness
  ) internal {
    // pick affixes
    (
      uint256[] memory statmodProtoEntities,
      uint256[] memory affixProtoEntities,
      uint256[] memory affixValues
    ) = LibPickAffixes.pickAffixes(
      components,
      affixPartIds,
      excludeAffixes,
      targetEntity,
      ilvl,
      randomness
    );
    // mint picked affixes
    lootMint(
      components,
      lootEntity,
      ilvl,
      affixPartIds,
      statmodProtoEntities,
      affixProtoEntities,
      affixValues
    );
  }

  function lootMint(
    IUint256Component components,
    uint256 lootEntity,
    uint256 ilvl,
    AffixPartId[] memory affixPartIds,
    uint256[] memory statmodProtoEntities,
    uint256[] memory affixProtoEntities,
    uint256[] memory affixValues
  ) internal {
    // save loot-specific data
    LootComponent lootComp = LootComponent(getAddressById(components, LootComponentID));
    lootComp.set(lootEntity, Loot({
      ilvl: ilvl,
      affixPartIds: affixPartIds,
      affixProtoEntities: affixProtoEntities,
      affixValues: affixValues
    }));
    // save loot as an effect prototype (the effect triggers on-equip)
    LibEffectPrototype.verifiedSet(
      components,
      lootEntity,
      EffectPrototype({
        removability: EffectRemovability.PERSISTENT,
        statmodProtoEntities: statmodProtoEntities,
        statmodValues: affixValues
      })
    );
  }
}