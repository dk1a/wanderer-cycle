// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { AffixAvailabilityTargetId, AffixPart, AffixPartId, Range } from "./types.sol";
import { AffixPrototypeAvailable } from "./codegen/tables/AffixPrototypeAvailable.sol";
import { AffixNaming } from "./codegen/tables/AffixNaming.sol";
import { AffixPrototype, AffixPrototypeData } from "./codegen/tables/AffixPrototype.sol";

import { DEFAULT_TIERS, MAX_ILVL } from "./constants.sol";

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
  error LibAddAffixPrototype_MalformedInput(string affixPrototypeName, uint32 maxIlvl);
  error LibAddAffixPrototype_InvalidStatmodBase();

  /// @dev Add `DEFAULT_TIERS` tiers of an affix
  /// (for affixes with non-standard tiers use `addAffixPrototype` directly)
  function addAffixPrototypes(
    string memory affixPrototypeName,
    bytes32 statmodBaseEntity,
    bytes32 exclusiveGroup,
    Range[DEFAULT_TIERS] memory ranges,
    AffixPart[][DEFAULT_TIERS] memory tieredAffixParts
  ) internal {
    for (uint32 i; i < tieredAffixParts.length; i++) {
      uint32 affixTier = i + 1;

      AffixPart[] memory affixParts = tieredAffixParts[i];
      if (affixParts.length == 0) continue;
      Range memory range = ranges[i];

      AffixPrototypeData memory proto = AffixPrototypeData({
        statmodBaseEntity: statmodBaseEntity,
        exclusiveGroup: exclusiveGroup,
        affixTier: affixTier,
        requiredLevel: _tierToDefaultRequiredIlvl(affixTier),
        min: range.min,
        max: range.max,
        name: affixPrototypeName
      });

      addAffixPrototype(proto, affixParts, MAX_ILVL);
    }
  }

  /// @dev Add a single affix tier with *custom* maxIlvl
  function addAffixPrototype(
    AffixPrototypeData memory affixProto,
    AffixPart[] memory affixParts,
    uint32 maxIlvl
  ) internal {
    if (maxIlvl == 0 || affixProto.requiredLevel > maxIlvl) {
      revert LibAddAffixPrototype_MalformedInput(affixProto.name, maxIlvl);
    }
    if (affixProto.statmodBaseEntity == 0) {
      revert LibAddAffixPrototype_InvalidStatmodBase();
    }

    bytes32 affixProtoEntity = getUniqueEntity();
    AffixPrototype.set(affixProtoEntity, affixProto);

    for (uint256 i; i < affixParts.length; i++) {
      AffixPartId partId = affixParts[i].partId;
      AffixAvailabilityTargetId affixAvailabilityTargetId = affixParts[i].affixAvailabilityTargetId;
      string memory label = affixParts[i].label;

      // which (partId+target) the affix is available for.
      // AffixPartId => namespace => target => affix prototype entity => label
      AffixNaming.set(partId, affixAvailabilityTargetId, affixProtoEntity, label);

      // availability component is basically a cache,
      // all its data is technically redundant, but greatly simplifies and speeds up queries.
      // target => partId => range(requiredIlvl, maxIlvl) => [affix prototype entities]
      for (uint32 ilvl = affixProto.requiredLevel; ilvl <= maxIlvl; ilvl++) {
        AffixPrototypeAvailable.push(partId, affixAvailabilityTargetId, ilvl, affixProtoEntity);
      }
    }
  }

  /// @dev Default ilvl requirement based on affix tier.
  /// (affixes with non-standard tiers shouldn't use this function)
  function _tierToDefaultRequiredIlvl(uint32 tier) internal pure returns (uint32 requiredIlvl) {
    // `tier` is not user-submitted, the asserts should never fail
    assert(tier > 0);
    assert(tier <= type(uint32).max);

    return (uint32(tier) - 1) * 4 + 1;
  }
}
