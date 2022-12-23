// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import {
  getEquipmentProtoEntity as eqp,
  EquipmentPrototypeComponent,
  ID as EquipmentPrototypeComponentID
} from "../equipment/EquipmentPrototypeComponent.sol";
import { StatmodPrototypeComponent, ID as StatmodPrototypeComponentID } from "../statmod/StatmodPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

import {
  getAffixProtoEntity,
  AffixPrototype,
  AffixPrototypeComponent,
  ID as AffixPrototypeComponentID
} from "../loot/AffixPrototypeComponent.sol";
import {
  getAffixNamingEntity,
  AffixPartId,
  AffixNamingComponent,
  ID as AffixNamingComponentID
} from "../loot/AffixNamingComponent.sol";
import {
  getAffixAvailabilityEntity,
  AffixAvailabilityComponent,
  ID as AffixAvailabilityComponentID
} from "../loot/AffixAvailabilityComponent.sol";

struct AffixPart {
  AffixPartId partId;
  uint256 equipmentProtoEntity;
  string label;
}

/// @dev Affixes have a complex structure, however most complexity is shoved into this BaseInit,
/// so the child inits and affix components are relatively simple.
///
/// Each affix has: name, associated statmod, tier.
/// Affixes with the same name (but different tiers) should share a statmod,
/// but for simplicity this is only enforced during initialization.
///
/// Tiers are 1,2,3,4..., higher means better affixes (tiers can be skipped).
/// Each affix's tier has 1 min-max range and a set of affix parts.
/// Each set of affix parts has:
///   2 explicits: prefix, suffix
///   1 implicit
/// Parts have labels. Explicits' labels don't depend on equipment prototypes. Implicits' label do.
/// affix => tier => {prefixLabel, suffixLabel}
/// affix => tier => equipmentProto => implicitLabel
abstract contract BaseInitAffixSystem is System {
  error BaseInitAffixSystem__MalformedInput();
  error BaseInitAffixSystem__InvalidEquipmentPrototype();
  error BaseInitAffixSystem__InvalidStatmodPrototype();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  /// @dev hardcoded number of currently expected tiers
  uint256 constant TIER_L = 4;
  /// @dev tier and required ilvl are always equal currently
  uint256 constant MAX_ILVL = 4;

  /// @dev affix value range
  struct Range {
    uint256 min;
    uint256 max;
  }

  /// @dev equipment label
  struct EL {
    uint256 equipmentProtoEntity;
    string label;
  }

  /// @dev Add all tiers of an affix
  function add(
    string memory affixName,
    uint256 statmodProtoEntity,
    Range[TIER_L] memory ranges,
    AffixPart[][TIER_L] memory tieredAffixParts
  ) internal {
    for (uint256 i; i < tieredAffixParts.length; i++) {
      uint256 tier = i + 1;

      AffixPart[] memory affixParts = tieredAffixParts[i];
      if (affixParts.length == 0) continue;
      Range memory range = ranges[i];

      AffixPrototype memory proto = AffixPrototype({
        tier: tier,
        statmodProtoEntity: statmodProtoEntity,
        requiredIlvl: tier,
        min: range.min,
        max: range.max
      });

      _addOne(
        affixName,
        proto,
        affixParts
      );
    }
  }

  /// @dev Add a single affix tier
  function _addOne(
    string memory affixName,
    AffixPrototype memory proto,
    AffixPart[] memory affixParts
  ) private {
    if (proto.requiredIlvl > MAX_ILVL) {
      revert BaseInitAffixSystem__MalformedInput();
    }

    // read-only components for validation
    EquipmentPrototypeComponent equipmentProtoComp
      = EquipmentPrototypeComponent(getAddressById(components, EquipmentPrototypeComponentID));
    StatmodPrototypeComponent statmodProtoComp
      = StatmodPrototypeComponent(getAddressById(components, StatmodPrototypeComponentID));

    if (!statmodProtoComp.has(proto.statmodProtoEntity)) {
      revert BaseInitAffixSystem__InvalidStatmodPrototype();
    }

    // write components
    AffixPrototypeComponent protoComp
      = AffixPrototypeComponent(getAddressById(components, AffixPrototypeComponentID));
    AffixNamingComponent namingComp
      = AffixNamingComponent(getAddressById(components, AffixNamingComponentID));
    AffixAvailabilityComponent availabilityComp
      = AffixAvailabilityComponent(getAddressById(components, AffixAvailabilityComponentID));
    NameComponent nameComp = NameComponent(getAddressById(components, NameComponentID));

    uint256 protoEntity = getAffixProtoEntity(affixName, proto.tier);
    protoComp.set(protoEntity, proto);
    nameComp.set(protoEntity, affixName);

    for (uint256 i; i < affixParts.length; i++) {
      AffixPartId partId = affixParts[i].partId;
      uint256 equipmentProtoEntity = affixParts[i].equipmentProtoEntity;
      string memory label = affixParts[i].label;

      // check that equipmentProtoEntity exists
      if (!equipmentProtoComp.has(equipmentProtoEntity)) {
        revert BaseInitAffixSystem__InvalidEquipmentPrototype();
      }

      // which (partId+equipmentProto) the affix is available for.
      // affixProto => equipmentProto => AffixPartId => label
      uint256 namingEntity = getAffixNamingEntity(partId, equipmentProtoEntity, protoEntity);
      namingComp.set(namingEntity, label);

      // availability component is basically a cache for given parameters,
      // all its data is technically redundant, but greatly simplifies and speeds up queries.
      // equipmentProto => partId => range(requiredIlvl, MAX_ILVL) => Set(affixProtos)
      for (uint256 ilvl = proto.requiredIlvl; ilvl < MAX_ILVL; ilvl++) {
        uint256 availabilityEntity = getAffixAvailabilityEntity(ilvl, partId, equipmentProtoEntity);
        availabilityComp.addItem(availabilityEntity, protoEntity);
      }
    }
  }

  /*//////////////////////////////////////////////////////////////////////////
                                    EQUIPMENT
  //////////////////////////////////////////////////////////////////////////*/

  function _allEquipment() internal pure returns (uint256[] memory r) {
    r = new uint256[](9);
    r[0] = eqp("Weapon");
    r[1] = eqp("Shield");
    r[2] = eqp("Hat");
    r[3] = eqp("Clothing");
    r[4] = eqp("Gloves");
    r[5] = eqp("Pants");
    r[6] = eqp("Boots");
    r[7] = eqp("Amulet");
    r[8] = eqp("Ring");
  }

  function _jewellery() internal pure returns (uint256[] memory r) {
    r = new uint256[](2);
    r[0] = eqp("Amulet");
    r[1] = eqp("Ring");
  }

  function _equipment(string[9] memory _labels) internal pure returns (EL[] memory _dynamic) {
    uint256[] memory allEquipment = _allEquipment();

    _dynamic = new EL[](_labels.length);
    uint256 j;
    for (uint256 i; i < _labels.length; i++) {
      if (bytes(_labels[i]).length > 0) {
        _dynamic[j] = EL({
          equipmentProtoEntity: allEquipment[i],
          label: _labels[i]
        });
        j++;
      }
    }
    // shorten dynamic length if necessary
    if (_labels.length != j) {
      /// @solidity memory-safe-assembly
      assembly {
        mstore(_dynamic, j)
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
    uint256[] memory explicits_equipmentProtoEntities,
    EL[] memory implicits_equipmentLabels
  ) internal pure returns (AffixPart[] memory) {
    AffixPart[][] memory separateParts = new AffixPart[][](3);
    // prefix
    separateParts[0] = _commonLabel(
      AffixPartId.PREFIX,
      explicits_equipmentProtoEntities,
      prefixLabel
    );
    // suffix
    separateParts[1] = _commonLabel(
      AffixPartId.SUFFIX,
      explicits_equipmentProtoEntities,
      suffixLabel
    );
    // implicit
    separateParts[2] = _individualLabels(
      AffixPartId.IMPLICIT,
      implicits_equipmentLabels
    );

    return _flatten(separateParts);
  }

  // explicits
  function _explicits(
    string memory prefixLabel,
    string memory suffixLabel,
    uint256[] memory explicits_equipmentProtoEntities
  ) internal pure returns (AffixPart[] memory) {
    AffixPart[][] memory separateParts = new AffixPart[][](2);
    // prefix
    separateParts[0] = _commonLabel(
      AffixPartId.PREFIX,
      explicits_equipmentProtoEntities,
      prefixLabel
    );
    // suffix
    separateParts[1] = _commonLabel(
      AffixPartId.SUFFIX,
      explicits_equipmentProtoEntities,
      suffixLabel
    );

    return _flatten(separateParts);
  }

  // implicits
  function _implicits(
    EL[] memory implicits_equipmentLabels
  ) internal pure returns (AffixPart[] memory) {
    return _individualLabels(
      AffixPartId.IMPLICIT,
      implicits_equipmentLabels
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

  // 1 label for multiple equipment entities
  function _commonLabel(
    AffixPartId partId,
    uint256[] memory equipmentProtoEntities,
    string memory label
  ) private pure returns (AffixPart[] memory affixParts) {
    affixParts = new AffixPart[](equipmentProtoEntities.length);

    for (uint256 i; i < equipmentProtoEntities.length; i++) {
      affixParts[i] = AffixPart({
        partId: partId,
        equipmentProtoEntity: equipmentProtoEntities[i],
        label: label
      });
    }
  }

  // 1 label for each equipment entity
  function _individualLabels(
    AffixPartId partId,
    EL[] memory equipmentLabels
  ) private pure returns (AffixPart[] memory affixParts) {
    affixParts = new AffixPart[](equipmentLabels.length);

    for (uint256 i; i < equipmentLabels.length; i++) {
      affixParts[i] = AffixPart({
        partId: partId,
        equipmentProtoEntity: equipmentLabels[i].equipmentProtoEntity,
        label: equipmentLabels[i].label
      });
    }
  }
}