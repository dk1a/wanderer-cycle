// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { StatmodPrototypeComponent, ID as StatmodPrototypeComponentID } from "../statmod/StatmodPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

import {
  getAffixProtoEntity,
  AffixPrototype,
  AffixPrototypeComponent,
  ID as AffixPrototypeComponentID
} from "../affix/AffixPrototypeComponent.sol";
import {
  getAffixNamingEntity,
  AffixPartId,
  AffixNamingComponent,
  ID as AffixNamingComponentID
} from "../affix/AffixNamingComponent.sol";
import {
  getAffixAvailabilityEntity,
  AffixAvailabilityComponent,
  ID as AffixAvailabilityComponentID
} from "../affix/AffixAvailabilityComponent.sol";
import {
  getAffixProtoGroupEntity,
  AffixPrototypeGroupComponent,
  ID as AffixPrototypeGroupComponentID
} from "../affix/AffixPrototypeGroupComponent.sol";

struct AffixPart {
  AffixPartId partId;
  uint256 targetEntity;
  string label;
}

/// @dev affix value range
struct Range {
  uint32 min;
  uint32 max;
}

/// @dev target label
struct TargetLabel {
  uint256 targetEntity;
  string label;
}

/// @dev number of usually expected tiers (some affixes may have non-standard tiers)
uint256 constant DEFAULT_TIERS = 4;
/// @dev number of currently expected ilvls
uint256 constant MAX_ILVL = 16;

/// @dev Default ilvl requirement based on affix tier.
/// (affixes with non-standard tiers shouldn't use this function)
function tierToDefaultRequiredIlvl(uint256 tier) pure returns (uint32 requiredIlvl) {
  // `tier` is not user-submitted, the asserts should never fail
  assert(tier > 0);
  assert(tier <= type(uint32).max);

  return (uint32(tier) - 1) * 4 + 1;
}

/// @dev Affixes have a complex structure, however most complexity is shoved into this BaseInit,
/// so the child inits and affix components are relatively simple.
///
/// Each affix has: name, associated statmod, tier.
/// Affixes with the same name (but different tiers) are grouped together via `AffixPrototypeGroupComponent`.
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
  error LibBaseInitAffix__MalformedInput(string affixName, uint256 maxIlvl);
  error LibBaseInitAffix__InvalidStatmodPrototype();

  struct Comps {
    // read
    StatmodPrototypeComponent statmodProto;
    // write
    AffixPrototypeComponent proto;
    AffixNamingComponent naming;
    AffixAvailabilityComponent availability;
    AffixPrototypeGroupComponent group;
    NameComponent name;
  }

  function getComps(IUint256Component components) internal view returns (Comps memory result) {
    // read
    result.statmodProto = StatmodPrototypeComponent(getAddressById(components, StatmodPrototypeComponentID));
    // write
    result.proto = AffixPrototypeComponent(getAddressById(components, AffixPrototypeComponentID));
    result.naming = AffixNamingComponent(getAddressById(components, AffixNamingComponentID));
    result.availability = AffixAvailabilityComponent(getAddressById(components, AffixAvailabilityComponentID));
    result.group = AffixPrototypeGroupComponent(getAddressById(components, AffixPrototypeGroupComponentID));
    result.name = NameComponent(getAddressById(components, NameComponentID));
  }

  /// @dev Add `DEFAULT_TIERS` tiers of an affix
  /// (for affixes with non-standard tiers use `addOne` directly)
  function add(
    Comps memory comps,
    string memory affixName,
    uint256 statmodProtoEntity,
    Range[DEFAULT_TIERS] memory ranges,
    AffixPart[][DEFAULT_TIERS] memory tieredAffixParts
  ) internal {
    for (uint32 i; i < tieredAffixParts.length; i++) {
      uint32 tier = i + 1;

      AffixPart[] memory affixParts = tieredAffixParts[i];
      if (affixParts.length == 0) continue;
      Range memory range = ranges[i];

      AffixPrototype memory proto = AffixPrototype({
        tier: tier,
        statmodProtoEntity: statmodProtoEntity,
        requiredIlvl: tierToDefaultRequiredIlvl(tier),
        min: range.min,
        max: range.max
      });

      addOne(
        comps,
        affixName,
        proto,
        affixParts
      );
    }
  }

  /// @dev Add a single affix tier with *default* maxIlvl
  function addOne(
    Comps memory comps,
    string memory affixName,
    AffixPrototype memory proto,
    AffixPart[] memory affixParts
  ) internal {
    addOne(comps, affixName, proto, affixParts, MAX_ILVL);
  }

  /// @dev Add a single affix tier with *custom* maxIlvl
  function addOne(
    Comps memory comps,
    string memory affixName,
    AffixPrototype memory proto,
    AffixPart[] memory affixParts,
    uint256 maxIlvl
  ) internal {
    if (maxIlvl == 0 || proto.requiredIlvl > maxIlvl) {
      revert LibBaseInitAffix__MalformedInput(affixName, maxIlvl);
    }
    if (!comps.statmodProto.has(proto.statmodProtoEntity)) {
      revert LibBaseInitAffix__InvalidStatmodPrototype();
    }

    uint256 protoEntity = getAffixProtoEntity(affixName, proto.tier);
    comps.proto.set(protoEntity, proto);
    comps.name.set(protoEntity, affixName);
    comps.group.set(protoEntity, getAffixProtoGroupEntity(affixName));

    for (uint256 i; i < affixParts.length; i++) {
      AffixPartId partId = affixParts[i].partId;
      uint256 targetEntity = affixParts[i].targetEntity;
      string memory label = affixParts[i].label;

      // which (partId+target) the affix is available for.
      // affixProto => target => AffixPartId => label
      uint256 namingEntity = getAffixNamingEntity(partId, targetEntity, protoEntity);
      comps.naming.set(namingEntity, label);

      // availability component is basically a cache,
      // all its data is technically redundant, but greatly simplifies and speeds up queries.
      // target => partId => range(requiredIlvl, maxIlvl) => Set(affixProtos)
      for (uint256 ilvl = proto.requiredIlvl; ilvl <= maxIlvl; ilvl++) {
        uint256 availabilityEntity = getAffixAvailabilityEntity(ilvl, partId, targetEntity);
        comps.availability.addItem(availabilityEntity, protoEntity);
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
    uint256[] memory explicits_targetEntities,
    TargetLabel[] memory implicits_targetLabels
  ) internal pure returns (AffixPart[] memory) {
    AffixPart[][] memory separateParts = new AffixPart[][](3);
    // prefix
    separateParts[0] = _commonLabel(
      AffixPartId.PREFIX,
      explicits_targetEntities,
      prefixLabel
    );
    // suffix
    separateParts[1] = _commonLabel(
      AffixPartId.SUFFIX,
      explicits_targetEntities,
      suffixLabel
    );
    // implicit
    separateParts[2] = _individualLabels(
      AffixPartId.IMPLICIT,
      implicits_targetLabels
    );

    return _flatten(separateParts);
  }

  // explicits
  function _explicits(
    string memory prefixLabel,
    string memory suffixLabel,
    uint256[] memory explicits_targetEntities
  ) internal pure returns (AffixPart[] memory) {
    AffixPart[][] memory separateParts = new AffixPart[][](2);
    // prefix
    separateParts[0] = _commonLabel(
      AffixPartId.PREFIX,
      explicits_targetEntities,
      prefixLabel
    );
    // suffix
    separateParts[1] = _commonLabel(
      AffixPartId.SUFFIX,
      explicits_targetEntities,
      suffixLabel
    );

    return _flatten(separateParts);
  }

  // implicits
  function _implicits(
    TargetLabel[] memory implicits_targetLabels
  ) internal pure returns (AffixPart[] memory) {
    return _individualLabels(
      AffixPartId.IMPLICIT,
      implicits_targetLabels
    );
  }

  // nothing
  function _none() internal pure returns (AffixPart[] memory) {
    return new AffixPart[](0);
  }

  // combine several arrays of affix parts into one
  function _flatten(
    AffixPart[][] memory separateParts
  ) private pure returns (AffixPart[] memory combinedParts) {
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
    uint256[] memory targetEntities,
    string memory label
  ) private pure returns (AffixPart[] memory affixParts) {
    affixParts = new AffixPart[](targetEntities.length);

    for (uint256 i; i < targetEntities.length; i++) {
      affixParts[i] = AffixPart({
        partId: partId,
        targetEntity: targetEntities[i],
        label: label
      });
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