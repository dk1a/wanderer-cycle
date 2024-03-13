// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AffixAvailable, AffixNaming, AffixPrototype, AffixPrototypeData, AffixProtoIndex, AffixProtoGroup, Affix, AffixData, Name } from "../codegen/index.sol";

import { AffixPartId } from "../codegen/common.sol";

struct AffixPart {
  AffixPartId partId;
  bytes32 targetEntity;
  string label;
}

/// @dev affix value range
struct Range {
  uint32 min;
  uint32 max;
}

/// @dev target label
struct TargetLabel {
  bytes32 targetEntity;
  string label;
}

/// @dev number of usually expected tiers (some affixes may have non-standard tiers)
uint32 constant DEFAULT_TIERS = 4;
/// @dev number of currently expected ilvls
uint32 constant MAX_ILVL = 16;

/// @dev Default ilvl requirement based on affix tier.
/// (affixes with non-standard tiers shouldn't use this function)
function tierToDefaultRequiredIlvl(uint32 tier) pure returns (uint32 requiredIlvl) {
  // `tier` is not user-submitted, the asserts should never fail
  assert(tier > 0);
  assert(tier <= type(uint32).max);

  return (uint32(tier) - 1) * 4 + 1;
}

/// @dev Affixes have a complex structure, however most complexity is shoved into this BaseInit,
/// so the child inits and affix tables are relatively simple.
///
/// Each affix has: name, associated statmod, tier.
/// Affixes with the same name (but different tiers) are grouped together via `AffixProtoGroup`.
///
/// Tiers are 1,2,3,4..., higher means better affixes (tiers can be skipped).
/// Each affix's tier has 1 min-max range and a set of affix parts.
/// Each set of affix parts has:
///   2 explicits: prefix, suffix
///   1 implicit
/// Parts have labels. Explicits' labels don't depend on targets. Implicits' label do.
/// affix => tier => {prefixLabel, suffixLabel}
/// affix => tier => targetEntity => implicitLabel
/// (targetEntity is e.g. equipmentProtoEntity)
library LibBaseInitAffix {
  error LibBaseInitAffix__MalformedInput(string affixName, uint32 maxIlvl);
  error LibBaseInitAffix__InvalidStatmodPrototype();

  /// @dev Add `DEFAULT_TIERS` tiers of an affix
  /// (for affixes with non-standard tiers use `addOne` directly)
  function add(
    string memory affixName,
    bytes32 statmodProtoEntity,
    Range[DEFAULT_TIERS] memory ranges,
    AffixPart[][DEFAULT_TIERS] memory tieredAffixParts
  ) internal {
    for (uint32 i; i < tieredAffixParts.length; i++) {
      uint32 tier = i + 1;

      AffixPart[] memory affixParts = tieredAffixParts[i];
      if (affixParts.length == 0) continue;
      Range memory range = ranges[i];

      AffixPrototypeData memory proto = AffixPrototypeData({
        statmodProtoEntity: statmodProtoEntity,
        tier: tier,
        requiredLevel: tierToDefaultRequiredIlvl(tier),
        min: range.min,
        max: range.max
      });

      addOne(affixName, proto, affixParts);
    }
  }

  /// @dev Add a single affix tier with *default* maxIlvl
  function addOne(
    string memory affixName,
    AffixPrototypeData memory affixProto,
    AffixPart[] memory affixParts
  ) internal {
    addOne(affixName, affixProto, affixParts, MAX_ILVL);
  }

  /// @dev Add a single affix tier with *custom* maxIlvl
  function addOne(
    string memory affixName,
    AffixPrototypeData memory affixProto,
    AffixPart[] memory affixParts,
    uint32 maxIlvl
  ) internal {
    bytes32 hashName = keccak256(abi.encodePacked(affixName));
    if (maxIlvl == 0 || affixProto.requiredLevel > maxIlvl) {
      revert LibBaseInitAffix__MalformedInput(affixName, maxIlvl);
    }
    if (affixProto.statmodProtoEntity == 0) {
      revert LibBaseInitAffix__InvalidStatmodPrototype();
    }

    bytes32 protoEntity = AffixProtoIndex.get(hashName, affixProto.tier);
    AffixPrototype.set(protoEntity, affixProto);
    Name.set(protoEntity, affixName);
    AffixProtoGroup.set(protoEntity, AffixProtoGroup.get(hashName));

    for (uint256 i; i < affixParts.length; i++) {
      AffixPartId partId = affixParts[i].partId;
      bytes32 targetEntity = affixParts[i].targetEntity;
      string memory label = affixParts[i].label;

      // which (partId+target) the affix is available for.
      // affixProto => target => AffixPartId => label
      AffixNaming.set(partId, targetEntity, protoEntity, label);

      // availability component is basically a cache,
      // all its data is technically redundant, but greatly simplifies and speeds up queries.
      // target => partId => range(requiredIlvl, maxIlvl) => Set(affixProtos)
      for (uint32 ilvl = affixProto.requiredLevel; ilvl <= maxIlvl; ilvl++) {
        bytes32 availabilityEntity = AffixAvailable.getItem(partId, targetEntity, ilvl, i);
        AffixAvailable.push(partId, protoEntity, ilvl, availabilityEntity);
      }
    }
  }

  /*//////////////////////////////////////////////////////////////////////////
                              AFFIX PARTS OPTIONS
  //////////////////////////////////////////////////////////////////////////*/

  // explicits + implicits
  function _affixes(
    string memory prefixLabel,
    string memory suffixLabel,
    bytes32[] memory explicits_targetEntities,
    TargetLabel[] memory implicits_targetLabels
  ) internal pure returns (AffixPart[] memory) {
    AffixPart[][] memory separateParts = new AffixPart[][](3);
    // prefix
    separateParts[0] = _commonLabel(AffixPartId.PREFIX, explicits_targetEntities, prefixLabel);
    // suffix
    separateParts[1] = _commonLabel(AffixPartId.SUFFIX, explicits_targetEntities, suffixLabel);
    // implicit
    separateParts[2] = _individualLabels(AffixPartId.IMPLICIT, implicits_targetLabels);

    return _flatten(separateParts);
  }

  // explicits
  function _explicits(
    string memory prefixLabel,
    string memory suffixLabel,
    bytes32[] memory explicits_targetEntities
  ) internal pure returns (AffixPart[] memory) {
    AffixPart[][] memory separateParts = new AffixPart[][](2);
    // prefix
    separateParts[0] = _commonLabel(AffixPartId.PREFIX, explicits_targetEntities, prefixLabel);
    // suffix
    separateParts[1] = _commonLabel(AffixPartId.SUFFIX, explicits_targetEntities, suffixLabel);

    return _flatten(separateParts);
  }

  // implicits
  function _implicits(TargetLabel[] memory implicits_targetLabels) internal pure returns (AffixPart[] memory) {
    return _individualLabels(AffixPartId.IMPLICIT, implicits_targetLabels);
  }

  // nothing
  function _none() internal pure returns (AffixPart[] memory) {
    return new AffixPart[](0);
  }

  // combine several arrays of affix parts into one
  function _flatten(AffixPart[][] memory separateParts) private pure returns (AffixPart[] memory combinedParts) {
    uint256 combinedLen;
    for (uint256 i; i < separateParts.length; i++) {
      combinedLen += separateParts[i].length;
    }

    combinedParts = new AffixPart[](combinedLen);

    uint256 totalIndex;
    for (uint256 i; i < separateParts.length; i++) {
      AffixPart[] memory separatePart = separateParts[i];
      for (uint256 j; j < separatePart.length; j++) {
        combinedParts[totalIndex] = separatePart[j];
        totalIndex++;
      }
    }
    return combinedParts;
  }

  // 1 label for multiple target entities
  function _commonLabel(
    AffixPartId partId,
    bytes32[] memory targetEntities,
    string memory label
  ) private pure returns (AffixPart[] memory affixParts) {
    affixParts = new AffixPart[](targetEntities.length);

    for (uint256 i; i < targetEntities.length; i++) {
      affixParts[i] = AffixPart({ partId: partId, targetEntity: targetEntities[i], label: label });
    }
  }

  // 1 label per each target entity
  function _individualLabels(
    AffixPartId partId,
    TargetLabel[] memory targetLabels
  ) private pure returns (AffixPart[] memory affixParts) {
    affixParts = new AffixPart[](targetLabels.length);

    for (uint256 i; i < targetLabels.length; i++) {
      affixParts[i] = AffixPart({
        partId: partId,
        targetEntity: targetLabels[i].targetEntity,
        label: targetLabels[i].label
      });
    }
  }
}
