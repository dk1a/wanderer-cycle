// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { entitySystem } from "../evefrontier/codegen/systems/EntitySystemLib.sol";

import { affixSystem } from "./codegen/systems/AffixSystemLib.sol";
import { AffixAvailabilityTargetId, AffixPartGeneral, AffixPartTargeted, AffixParts, AffixPartId, Range } from "./types.sol";
import { AffixPrototypeAvailable } from "./codegen/tables/AffixPrototypeAvailable.sol";
import { AffixNaming } from "./codegen/tables/AffixNaming.sol";
import { AffixNamingTargeted } from "./codegen/tables/AffixNamingTargeted.sol";
import { AffixPrototype, AffixPrototypeData } from "./codegen/tables/AffixPrototype.sol";

import { MAX_AFFIX_TIER } from "./constants.sol";

// TODO rewrite the comments, much is wrong after all the refactors
/// @dev Affixes have a complex structure, however most complexity is shoved into LibAddAffixPrototype and LibAffixParts,
/// so the child inits and affix tables are relatively simple.
///
/// Each affix has: name, associated statmod, tier.
///
/// Tiers are 1,2,3,4..., higher means better affixes (tiers can be skipped).
/// Each affix's tier has 1 min-max range and a set of affix parts.
/// Each set of affix parts has:
///   2 explicits: prefix, suffix
///   1 implicit
/// Parts have labels. Explicits' labels don't depend on targets. Implicits' label do.
/// affix => tier => {prefixLabel, suffixLabel}
/// affix => tier => affixAvailabilityTargetId => implicitLabel
library LibAddAffixPrototype {
  error LibAddAffixPrototype_MalformedInput(string affixPrototypeName, uint32 maxTier);
  error LibAddAffixPrototype_InvalidStatmodBase();

  /// @dev Add `MAX_AFFIX_TIER` tiers of an affix
  /// (for affixes with non-standard tiers use `addAffixPrototype` directly)
  function addAffixPrototypes(
    string memory affixPrototypeName,
    bytes32 statmodEntity,
    bytes32 exclusiveGroup,
    Range[MAX_AFFIX_TIER] memory ranges,
    AffixParts[MAX_AFFIX_TIER] memory tieredAffixParts
  ) internal {
    for (uint32 i; i < tieredAffixParts.length; i++) {
      uint32 affixTier = i + 1;

      AffixParts memory affixParts = tieredAffixParts[i];
      if (affixParts.general.length == 0 && affixParts.targeted.length == 0) continue;
      Range memory range = ranges[i];

      AffixPrototypeData memory proto = AffixPrototypeData({
        statmodEntity: statmodEntity,
        exclusiveGroup: exclusiveGroup,
        affixTier: affixTier,
        min: range.min,
        max: range.max,
        name: affixPrototypeName
      });

      addAffixPrototype(proto, affixParts, MAX_AFFIX_TIER);
    }
  }

  /// @dev Add a single affix tier with *custom* maxTier
  function addAffixPrototype(
    AffixPrototypeData memory affixProto,
    AffixParts memory affixParts,
    uint32 maxTier
  ) internal returns (bytes32 affixProtoEntity) {
    if (maxTier == 0 || affixProto.affixTier > maxTier) {
      revert LibAddAffixPrototype_MalformedInput(affixProto.name, maxTier);
    }
    if (affixProto.statmodEntity == 0) {
      revert LibAddAffixPrototype_InvalidStatmodBase();
    }

    affixProtoEntity = _registerAffixPrototype();
    AffixPrototype.set(affixProtoEntity, affixProto);

    for (uint256 i; i < affixParts.general.length; i++) {
      AffixPartGeneral memory affixPart = affixParts.general[i];

      // affix prototype entity => affix part id => label
      AffixNaming.set(affixProtoEntity, affixPart.partId, affixPart.label);

      for (uint256 j; j < affixPart.targetIds.length; j++) {
        _addTierRangeAvailability(
          affixPart.partId,
          affixPart.targetIds[j],
          affixProto.affixTier,
          maxTier,
          affixProtoEntity
        );
      }
    }

    for (uint256 i; i < affixParts.targeted.length; i++) {
      AffixPartTargeted memory affixPart = affixParts.targeted[i];

      // affix prototype entity => affix part id => affix availability target id => label
      AffixNamingTargeted.set(affixProtoEntity, affixPart.partId, affixPart.targetId, affixPart.label);

      _addTierRangeAvailability(affixPart.partId, affixPart.targetId, affixProto.affixTier, maxTier, affixProtoEntity);
    }
  }

  // availability component is basically a cache,
  // all its data is technically redundant, but greatly simplifies and speeds up queries.
  // partId => target => range(minTier, maxTier) => [affix prototype entities]
  function _addTierRangeAvailability(
    AffixPartId partId,
    AffixAvailabilityTargetId targetId,
    uint32 minTier,
    uint32 maxTier,
    bytes32 affixProtoEntity
  ) internal {
    for (uint32 affixTier = minTier; affixTier <= maxTier; affixTier++) {
      AffixPrototypeAvailable.push(partId, targetId, affixTier, affixProtoEntity);
    }
  }

  function _registerAffixPrototype() internal returns (bytes32 affixProtoEntity) {
    ResourceId[] memory systemIds = new ResourceId[](1);
    systemIds[0] = affixSystem.toResourceId();

    return bytes32(entitySystem.registerClass(systemIds));
  }
}
