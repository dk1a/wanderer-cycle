// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { LibBaseInitAffix as b, Range, TargetLabel, DEFAULT_TIERS, AffixPrototypeData } from "./LibBaseInitAffix.sol";

import { StatmodOp, EleStat } from "../../../CustomTypes.sol";
import { StatmodTopics } from "../../statmod/StatmodTopic.sol";
import { MapTypes } from "../map/MapType.sol";
import { MapTypeAffixAvailability } from "../codegen/index.sol";

library LibInitMapAffix {
  function init() internal {
    MapTypeAffixAvailability.set("random_map", getUniqueEntity());

    bytes32[] memory affixAvailabilityEntities = new bytes32[](1);
    affixAvailabilityEntities[0] = MapTypeAffixAvailability.get("random_map");

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

    b.add(
      "map life",
      StatmodTopics.LIFE.toStatmodEntity(StatmodOp.ADD, EleStat.NONE),
      resourceRanges,
      [
        b._explicits("Hale", "of Haleness", affixAvailabilityEntities),
        b._explicits("Healthful", "of Health", affixAvailabilityEntities),
        b._explicits("Robust", "of Robustness", affixAvailabilityEntities),
        b._explicits("Stalwart", "of Stalwart Body", affixAvailabilityEntities)
      ]
    );

    // ATTRIBUTES

    b.add(
      "map strength",
      StatmodTopics.STRENGTH.toStatmodEntity(StatmodOp.ADD, EleStat.NONE),
      attrRanges,
      [
        b._explicits("Brutish", "of the Brute", affixAvailabilityEntities),
        b._explicits("Canine", "of the Wolf", affixAvailabilityEntities),
        b._explicits("Bearish", "of the Bear", affixAvailabilityEntities),
        b._explicits("Lionheart", "of the Lion", affixAvailabilityEntities)
      ]
    );

    b.add(
      "map arcana",
      StatmodTopics.ARCANA.toStatmodEntity(StatmodOp.ADD, EleStat.NONE),
      attrRanges,
      [
        b._explicits("Studious", "of the Student", affixAvailabilityEntities),
        b._explicits("Observant", "of the Goat", affixAvailabilityEntities),
        b._explicits("Seercraft", "of the Seer", affixAvailabilityEntities),
        b._explicits("Mystical", "of Mysticism", affixAvailabilityEntities)
      ]
    );

    b.add(
      "map dexterity",
      StatmodTopics.DEXTERITY.toStatmodEntity(StatmodOp.ADD, EleStat.NONE),
      attrRanges,
      [
        b._explicits("Slick", "of the Mongoose", affixAvailabilityEntities),
        b._explicits("Sly", "of the Fox", affixAvailabilityEntities),
        b._explicits("Swift", "of the Falcon", affixAvailabilityEntities),
        b._explicits("Agile", "of the Panther", affixAvailabilityEntities)
      ]
    );

    // ATTACK

    b.add(
      "map physical attack",
      StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.ADD, EleStat.PHYSICAL),
      attackRanges,
      [
        b._explicits("Irate", "of Ire", affixAvailabilityEntities),
        b._explicits("Bullish", "of the Bull", affixAvailabilityEntities),
        b._explicits("Raging", "of Rage", affixAvailabilityEntities),
        b._explicits("Furious", "of Fury", affixAvailabilityEntities)
      ]
    );

    b.add(
      "map fire attack",
      StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.ADD, EleStat.FIRE),
      attackRanges,
      [
        b._explicits("Heated", "of Heat", affixAvailabilityEntities),
        b._explicits("Smouldering", "of Coals", affixAvailabilityEntities),
        b._explicits("Fiery", "of Fire", affixAvailabilityEntities),
        b._explicits("Flaming", "of Flames", affixAvailabilityEntities)
      ]
    );

    b.add(
      "map cold attack",
      StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.ADD, EleStat.COLD),
      attackRanges,
      [
        b._explicits("Chilled", "of Chills", affixAvailabilityEntities),
        b._explicits("Icy", "of Ice", affixAvailabilityEntities),
        b._explicits("Cold", "of Cold", affixAvailabilityEntities),
        b._explicits("Frosted", "of Frost", affixAvailabilityEntities)
      ]
    );

    b.add(
      "map poison attack",
      StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.ADD, EleStat.POISON),
      attackRanges,
      [
        b._explicits("Sickly", "of Sickness", affixAvailabilityEntities),
        b._explicits("Poisonous", "of Poison", affixAvailabilityEntities),
        b._explicits("Venomous", "of Venom", affixAvailabilityEntities),
        b._explicits("Malignant", "of Malignancy", affixAvailabilityEntities)
      ]
    );

    // RESISTANCE

    b.add(
      "map physical resistance",
      StatmodTopics.RESISTANCE.toStatmodEntity(StatmodOp.ADD, EleStat.PHYSICAL),
      resistanceRanges,
      [
        b._explicits("Toughened", "of the Oyster", affixAvailabilityEntities),
        b._explicits("Sturdy", "of the Lobster", affixAvailabilityEntities),
        b._explicits("Reinforced", "of the Nautilus", affixAvailabilityEntities),
        b._explicits("Fortified", "of the Tortoise", affixAvailabilityEntities)
      ]
    );

    b.add(
      "map fire resistance",
      StatmodTopics.RESISTANCE.toStatmodEntity(StatmodOp.ADD, EleStat.FIRE),
      resistanceRanges,
      [
        b._explicits("Heatproof", "of the Whelpling", affixAvailabilityEntities),
        b._explicits("Dousing", "of the Salamander", affixAvailabilityEntities),
        b._explicits("Fireproof", "of Fire Warding", affixAvailabilityEntities),
        b._explicits("Flamewarded", "of Flame Warding", affixAvailabilityEntities)
      ]
    );

    b.add(
      "map cold resistance",
      StatmodTopics.RESISTANCE.toStatmodEntity(StatmodOp.ADD, EleStat.COLD),
      resistanceRanges,
      [
        b._explicits("Insulating", "of the Penguin", affixAvailabilityEntities),
        b._explicits("Warming", "of the Walrus", affixAvailabilityEntities),
        b._explicits("Coldproof", "of Cold Warding", affixAvailabilityEntities),
        b._explicits("Frostwarded", "of Frost Warding", affixAvailabilityEntities)
      ]
    );

    b.add(
      "map poison resistance",
      StatmodTopics.RESISTANCE.toStatmodEntity(StatmodOp.ADD, EleStat.POISON),
      resistanceRanges,
      [
        b._explicits("Wholesome", "of the Opossum", affixAvailabilityEntities),
        b._explicits("Inoculative", "of the Snake", affixAvailabilityEntities),
        b._explicits("Poisonward", "of Poison Warding", affixAvailabilityEntities),
        b._explicits("Venomward", "of Venom Warding", affixAvailabilityEntities)
      ]
    );
  }

  /// @dev Add a map-specific implicit affix.
  /// Non-standard affix tiers: tier == map level == affix value == requiredIlvl == maxIlvl
  function addMapLevel(string memory name, string memory label, uint32 level) internal {
    TargetLabel[] memory mapLabels = new TargetLabel[](1);
    mapLabels[0] = TargetLabel({ targetEntity: MapTypeAffixAvailability.get("random_map"), label: label });

    b.addOne(
      name,
      AffixPrototypeData({
        tier: level,
        statmodProtoEntity: StatmodTopics.LEVEL.toStatmodEntity(StatmodOp.BADD, EleStat.NONE),
        requiredLevel: level,
        min: level,
        max: level
      }),
      b._implicits(mapLabels),
      level
    );
  }
}
