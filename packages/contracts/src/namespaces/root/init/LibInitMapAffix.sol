// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { AffixAvailabilityTargetId, LibAffixParts as b } from "../../affix/LibAffixParts.sol";
import { LibAddAffixPrototype } from "../../affix/LibAddAffixPrototype.sol";
import { AffixPrototypeData } from "../../affix/codegen/tables/AffixPrototype.sol";
import { AffixPart, Range, TargetLabel } from "../../affix/types.sol";
import { DEFAULT_TIERS } from "../../affix/constants.sol";

import { StatmodTopics } from "../../statmod/StatmodTopic.sol";
import { StatmodOp, EleStat } from "../../../CustomTypes.sol";
import { MapAffixAvailabilityTargetIds } from "../../map/MapAffixAvailabilityTargetIds.sol";

library LibInitMapAffix {
  function init() internal {
    AffixAvailabilityTargetId[] memory targetIds = new AffixAvailabilityTargetId[](1);
    targetIds[0] = MapAffixAvailabilityTargetIds.RANDOM_MAP;

    // TODO balance map ranges, they're even worse than equipment ranges

    Range[DEFAULT_TIERS] memory resourceRanges = [Range(4, 8), Range(12, 18), Range(24, 32), Range(40, 50)];

    Range[DEFAULT_TIERS] memory attrRanges = [Range(1, 1), Range(2, 2), Range(3, 3), Range(4, 4)];

    Range[DEFAULT_TIERS] memory attackRanges = [Range(2, 3), Range(6, 8), Range(10, 13), Range(14, 18)];

    Range[DEFAULT_TIERS] memory resistanceRanges = [Range(20, 30), Range(40, 50), Range(60, 70), Range(80, 90)];

    // LEVEL

    addMapLevel("map level 1", "Meadows", 1);
    addMapLevel("map level 2", "Plains", 2);
    addMapLevel("map level 3", "Valley", 3);
    addMapLevel("map level 4", "Hills", 4);
    addMapLevel("map level 5", "Woods", 5);
    addMapLevel("map level 6", "Thicket", 6);
    addMapLevel("map level 7", "Wetlands", 7);
    addMapLevel("map level 8", "Swamp", 8);
    addMapLevel("map level 9", "Wastes", 9);
    addMapLevel("map level 10", "Mountains", 10);
    addMapLevel("map level 11", "Caves", 11);
    addMapLevel("map level 12", "Ruins", 12);

    // TODO customize map affix labels, atm they're just copypasted from equipment

    // RESOURCES

    add(
      "map life",
      StatmodTopics.LIFE.toStatmodEntity(StatmodOp.ADD, EleStat.NONE),
      resourceRanges,
      [
        b._explicits("Hale", "of Haleness", targetIds),
        b._explicits("Healthful", "of Health", targetIds),
        b._explicits("Robust", "of Robustness", targetIds),
        b._explicits("Stalwart", "of Stalwart Body", targetIds)
      ]
    );

    // ATTRIBUTES

    add(
      "map strength",
      StatmodTopics.STRENGTH.toStatmodEntity(StatmodOp.ADD, EleStat.NONE),
      attrRanges,
      [
        b._explicits("Brutish", "of the Brute", targetIds),
        b._explicits("Canine", "of the Wolf", targetIds),
        b._explicits("Bearish", "of the Bear", targetIds),
        b._explicits("Lionheart", "of the Lion", targetIds)
      ]
    );

    add(
      "map arcana",
      StatmodTopics.ARCANA.toStatmodEntity(StatmodOp.ADD, EleStat.NONE),
      attrRanges,
      [
        b._explicits("Studious", "of the Student", targetIds),
        b._explicits("Observant", "of the Goat", targetIds),
        b._explicits("Seercraft", "of the Seer", targetIds),
        b._explicits("Mystical", "of Mysticism", targetIds)
      ]
    );

    add(
      "map dexterity",
      StatmodTopics.DEXTERITY.toStatmodEntity(StatmodOp.ADD, EleStat.NONE),
      attrRanges,
      [
        b._explicits("Slick", "of the Mongoose", targetIds),
        b._explicits("Sly", "of the Fox", targetIds),
        b._explicits("Swift", "of the Falcon", targetIds),
        b._explicits("Agile", "of the Panther", targetIds)
      ]
    );

    // ATTACK

    add(
      "map physical attack",
      StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.ADD, EleStat.PHYSICAL),
      attackRanges,
      [
        b._explicits("Irate", "of Ire", targetIds),
        b._explicits("Bullish", "of the Bull", targetIds),
        b._explicits("Raging", "of Rage", targetIds),
        b._explicits("Furious", "of Fury", targetIds)
      ]
    );

    add(
      "map fire attack",
      StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.ADD, EleStat.FIRE),
      attackRanges,
      [
        b._explicits("Heated", "of Heat", targetIds),
        b._explicits("Smouldering", "of Coals", targetIds),
        b._explicits("Fiery", "of Fire", targetIds),
        b._explicits("Flaming", "of Flames", targetIds)
      ]
    );

    add(
      "map cold attack",
      StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.ADD, EleStat.COLD),
      attackRanges,
      [
        b._explicits("Chilled", "of Chills", targetIds),
        b._explicits("Icy", "of Ice", targetIds),
        b._explicits("Cold", "of Cold", targetIds),
        b._explicits("Frosted", "of Frost", targetIds)
      ]
    );

    add(
      "map poison attack",
      StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.ADD, EleStat.POISON),
      attackRanges,
      [
        b._explicits("Sickly", "of Sickness", targetIds),
        b._explicits("Poisonous", "of Poison", targetIds),
        b._explicits("Venomous", "of Venom", targetIds),
        b._explicits("Malignant", "of Malignancy", targetIds)
      ]
    );

    // RESISTANCE

    add(
      "map physical resistance",
      StatmodTopics.RESISTANCE.toStatmodEntity(StatmodOp.ADD, EleStat.PHYSICAL),
      resistanceRanges,
      [
        b._explicits("Toughened", "of the Oyster", targetIds),
        b._explicits("Sturdy", "of the Lobster", targetIds),
        b._explicits("Reinforced", "of the Nautilus", targetIds),
        b._explicits("Fortified", "of the Tortoise", targetIds)
      ]
    );

    add(
      "map fire resistance",
      StatmodTopics.RESISTANCE.toStatmodEntity(StatmodOp.ADD, EleStat.FIRE),
      resistanceRanges,
      [
        b._explicits("Heatproof", "of the Whelpling", targetIds),
        b._explicits("Dousing", "of the Salamander", targetIds),
        b._explicits("Fireproof", "of Fire Warding", targetIds),
        b._explicits("Flamewarded", "of Flame Warding", targetIds)
      ]
    );

    add(
      "map cold resistance",
      StatmodTopics.RESISTANCE.toStatmodEntity(StatmodOp.ADD, EleStat.COLD),
      resistanceRanges,
      [
        b._explicits("Insulating", "of the Penguin", targetIds),
        b._explicits("Warming", "of the Walrus", targetIds),
        b._explicits("Coldproof", "of Cold Warding", targetIds),
        b._explicits("Frostwarded", "of Frost Warding", targetIds)
      ]
    );

    add(
      "map poison resistance",
      StatmodTopics.RESISTANCE.toStatmodEntity(StatmodOp.ADD, EleStat.POISON),
      resistanceRanges,
      [
        b._explicits("Wholesome", "of the Opossum", targetIds),
        b._explicits("Inoculative", "of the Snake", targetIds),
        b._explicits("Poisonward", "of Poison Warding", targetIds),
        b._explicits("Venomward", "of Venom Warding", targetIds)
      ]
    );
  }

  function add(
    string memory affixPrototypeName,
    bytes32 statmodEntity,
    Range[DEFAULT_TIERS] memory ranges,
    AffixPart[][DEFAULT_TIERS] memory tieredAffixParts
  ) internal {
    bytes32 exclusiveGroup = bytes32(bytes(affixPrototypeName));
    LibAddAffixPrototype.addAffixPrototypes(
      affixPrototypeName,
      statmodEntity,
      exclusiveGroup,
      ranges,
      tieredAffixParts
    );
  }

  /// @dev Add a map-specific implicit affix.
  /// Non-standard affix tiers: tier == map level == affix value == requiredIlvl == maxIlvl
  function addMapLevel(string memory name, string memory label, uint32 level) internal {
    TargetLabel[] memory mapLabels = new TargetLabel[](1);
    mapLabels[0] = TargetLabel({ affixAvailabilityTargetId: MapAffixAvailabilityTargetIds.RANDOM_MAP, label: label });

    LibAddAffixPrototype.addAffixPrototype(
      AffixPrototypeData({
        statmodEntity: StatmodTopics.LEVEL.toStatmodEntity(StatmodOp.BADD, EleStat.NONE),
        exclusiveGroup: "",
        affixTier: level,
        requiredLevel: level,
        min: level,
        max: level,
        name: name
      }),
      b._implicits(mapLabels),
      level
    );
  }
}
