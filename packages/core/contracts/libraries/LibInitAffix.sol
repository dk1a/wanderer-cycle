// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import {
  MAX_ILVL,
  AffixPart,
  AffixPartId,
  AffixPrototype,
  AffixInitSystem,
  ID as AffixInitSystemID
} from "../loot/AffixInitSystem.sol";
import { AFFIX_PARTS_LENGTH } from "../loot/AffixNamingComponent.sol";
import { getEquipmentProtoEntity as eqp } from "../equipment/EquipmentPrototypeComponent.sol";
import { Topics, Op, Element } from "../charstat/Topics.sol";

/// @dev Affixes have a complex structure, however most complexity is shoved into initialization,
/// so the components are relatively simple.
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
library LibInitAffix {
  uint256 constant TIER_L = 4;

  struct Range {
    uint256 min;
    uint256 max;
  }

  struct EL {
    uint256 equipmentProtoEntity;
    string label;
  }

  struct Option {
    bool none;
    AffixPart[] affixParts;
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
    if (_labels.length != j) {
      /// @solidity memory-safe-assembly
      assembly {
        mstore(_dynamic, j)
      }
    }
  }

  /*//////////////////////////////////////////////////////////////////////////
                                    INITIALIZE
  //////////////////////////////////////////////////////////////////////////*/

  function initialize(IWorld world) internal {
    Range[TIER_L] memory resourceRanges = [
      Range(1, 4),
      Range(5, 6),
      Range(7, 9),
      Range(10, 12)
    ];

    _add(
      world,
      "life",
      Topics.LIFE.toStatmodEntity(Op.ADD, Element.ALL),
      resourceRanges,
      [
        _both(
          "Hale", "of Haleness",
          _allEquipment(),
          _equipment([
            "",
            "Brawler's Shield",
            "Brawler's Headband",
            "Brawler's Vest",
            "Brawler's Bracers",
            "Brawler's Pants",
            "Brawler's Boots",
            "Brawler's Necklace",
            "Brawler's Ring"
          ])
        ),
        _both(
          "Healthful", "of Health",
          _allEquipment(),
          _equipment([
            "",
            "Infantry Shield",
            "Infantry Helmet",
            "Infantry Brigandine",
            "Infantry Gloves",
            "Infantry Trousers",
            "Infantry Boots",
            "Infantry Pendant",
            "Infantry Ring"
          ])
        ),
        _both(
          "Robust", "of Robustness",
          _allEquipment(),
          _equipment([
            "",
            "Warrior Shield",
            "Warrior Helmet",
            "Warrior Armor",
            "Warrior Gauntlets",
            "Warrior Legguards",
            "Warrior Greaves",
            "Warrior Amulet",
            "Warrior Ring"
          ])
        ),
        _both(
          "Stalwart", "of Stalwart Body",
          _allEquipment(),
          _equipment([
            "",
            "Crusader Shield",
            "Crusader Helmet",
            "Crusader Plate",
            "Crusader Gauntlets",
            "Crusader Legguards",
            "Crusader Greaves",
            "Crusader Amulet",
            "Crusader Signet"
          ])
        )
      ]
    );

    _add(
      world,
      "life regen",
      Topics.LIFE_GAINED_PER_TURN.toStatmodEntity(Op.ADD, Element.ALL),
      resourceRanges,
      [
        _explicits(
          "Salubrious", "of Salubrity",
          _jewellery()
        ),
        _explicits(
          "Recuperative", "of Recuperation",
          _allEquipment()
        ),
        _explicits(
          "Restorative", "of Restoration",
          _allEquipment()
        ),
        _explicits(
          "Rejuvenating", "of Rejuvenation",
          _allEquipment()
        )
      ]
    );

    _add(
      world,
      "mana",
      Topics.MANA.toStatmodEntity(Op.ADD, Element.ALL),
      resourceRanges,
      [
        _both(
          "Calm", "of Calm",
          _allEquipment(),
          _equipment([
            "",
            "Student's Shield",
            "Student's Cap",
            "Student's Robe",
            "Student's Gloves",
            "Student's Pants",
            "Student's Boots",
            "Student's Necklace",
            "Student's Ring"
          ])
        ),
        _both(
          "Serene", "of Serenity",
          _allEquipment(),
          _equipment([
            "",
            "Scholar's Shield",
            "Scholar's Cap",
            "Scholar's Robe",
            "Scholar's Gloves",
            "Scholar's Pants",
            "Scholar's Boots",
            "Scholar's Pendant",
            "Scholar's Ring"
          ])
        ),
        _both(
          "Tranquil", "of Tranquility",
          _allEquipment(),
          _equipment([
            "",
            "Mage Shield",
            "Mage Hat",
            "Mage Vestment",
            "Mage Gloves",
            "Mage Pants",
            "Mage Boots",
            "Mage Amulet",
            "Mage Ring"
          ])
        ),
        _both(
          "Halcyon", "of Halcyon Mind",
          _allEquipment(),
          _equipment([
            "",
            "Sage Shield",
            "Sage Circlet",
            "Sage Vestment",
            "Sage Gloves",
            "Sage Pants",
            "Sage Boots",
            "Sage Amulet",
            "Sage Signet"
          ])
        )
      ]
    );

    _add(
      world,
      "mana regen",
      Topics.MANA_GAINED_PER_TURN.toStatmodEntity(Op.ADD, Element.ALL),
      resourceRanges,
      [
        _explicits(
          "Drowsy", "of Drowsiness",
          _jewellery()
        ),
        _explicits(
          "Sleepy", "of Sleepiness",
          _allEquipment()
        ),
        _explicits(
          "Slumberous", "of Slumber",
          _allEquipment()
        ),
        _explicits(
          "Somnolent", "of Somnolence",
          _allEquipment()
        )
      ]
    );
  }

  /*//////////////////////////////////////////////////////////////////////////
                              AFFIX PARTS OPTIONS
  //////////////////////////////////////////////////////////////////////////*/

  // explicits + implicits
  function _both(
    string memory prefixLabel,
    string memory suffixLabel,
    uint256[] memory explicits_equipmentProtoEntities,
    EL[] memory implicits_equipmentLabels
  ) internal pure returns (Option memory opt) {
    opt.none = false;

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

    opt.affixParts = _flatten(separateParts);
  }

  // explicits
  function _explicits(
    string memory prefixLabel,
    string memory suffixLabel,
    uint256[] memory explicits_equipmentProtoEntities
  ) internal pure returns (Option memory opt) {
    opt.none = false;

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

    opt.affixParts = _flatten(separateParts);
  }

  // implicits
  function _implicits(
    EL[] memory implicits_equipmentLabels
  ) internal pure returns (Option memory opt) {
    opt.none = false;

    opt.affixParts = _individualLabels(
      AffixPartId.IMPLICIT,
      implicits_equipmentLabels
    );
  }

  // nothing
  function _none() internal pure returns (Option memory opt) {
    opt.none = true;
  }

  // combine several arrays of affix parts into one
  function _flatten(
    AffixPart[][] memory separateParts
  ) internal pure returns (AffixPart[] memory combinedParts) {
    uint256 combinedLen;
    for (uint256 i; i < separateParts.length; i++) {
      combinedLen = separateParts[i].length;
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
  ) internal pure returns (AffixPart[] memory affixParts) {
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
  ) internal pure returns (AffixPart[] memory affixParts) {
    affixParts = new AffixPart[](equipmentLabels.length);

    for (uint256 i; i < equipmentLabels.length; i++) {
      affixParts[i] = AffixPart({
        partId: partId,
        equipmentProtoEntity: equipmentLabels[i].equipmentProtoEntity,
        label: equipmentLabels[i].label
      });
    }
  }

  /*//////////////////////////////////////////////////////////////////////////
                                EXECUTE WRAPPER
  //////////////////////////////////////////////////////////////////////////*/

  function _add(
    IWorld world,
    string memory affixName,
    uint256 statmodProtoEntity,
    Range[TIER_L] memory ranges,
    Option[TIER_L] memory opts
  ) internal {
    AffixInitSystem system = AffixInitSystem(getAddressById(world.systems(), AffixInitSystemID));

    for (uint256 i; i < opts.length; i++) {
      Option memory opt = opts[i];
      if (opt.none) continue;
      Range memory range = ranges[i];

      uint256 tier = i + 1;

      AffixPrototype memory proto = AffixPrototype({
        tier: tier,
        statmodProtoEntity: statmodProtoEntity,
        requiredIlvl: tier,
        min: range.min,
        max: range.max
      });
      AffixPart[] memory affixParts = opt.affixParts;

      system.executeTyped(
        affixName,
        proto,
        affixParts
      );
    }
  }
}