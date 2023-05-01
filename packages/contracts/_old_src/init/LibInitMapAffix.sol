// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibBaseInitAffix as b, Range, TargetLabel, DEFAULT_TIERS, AffixPrototype } from "./LibBaseInitAffix.sol";

import { Topics, Op, Element } from "../charstat/Topics.sol";
import { MapPrototypes } from "../map/MapPrototypes.sol";

library LibInitMapAffix {
  function init(IWorld world) internal {
    b.Comps memory comps = b.getComps(world.components());

    // TODO balance map ranges, they're even worse than equipment ranges

    Range[DEFAULT_TIERS] memory resourceRanges = [
      Range(4, 8),
      Range(12, 18),
      Range(24, 32),
      Range(40, 50)
    ];

    Range[DEFAULT_TIERS] memory attrRanges = [
      Range(1, 1),
      Range(2, 2),
      Range(3, 3),
      Range(4, 4)
    ];

    Range[DEFAULT_TIERS] memory attackRanges = [
      Range(2, 3),
      Range(6, 8),
      Range(10, 13),
      Range(14, 18)
    ];

    Range[DEFAULT_TIERS] memory resistanceRanges = [
      Range(20, 30),
      Range(40, 50),
      Range(60, 70),
      Range(80, 90)
    ];

    // LEVEL

    addMapLevel(comps, "map level 1", "Meadows", 1);
    addMapLevel(comps, "map level 2", "Plains", 2);
    addMapLevel(comps, "map level 3", "Valley", 3);
    addMapLevel(comps, "map level 4", "Hills", 4);
    addMapLevel(comps, "map level 5", "Woods", 5);
    addMapLevel(comps, "map level 6", "Thicket", 6);
    addMapLevel(comps, "map level 7", "Wetlands", 7);
    addMapLevel(comps, "map level 8", "Swamp", 8);
    addMapLevel(comps, "map level 9", "Wastes", 9);
    addMapLevel(comps, "map level 10", "Mountains", 10);
    addMapLevel(comps, "map level 11", "Caves", 11);
    addMapLevel(comps, "map level 12", "Ruins", 12);

    // TODO customize map affix labels, atm they're just copypasted from equipment

    // RESOURCES

    b.add(
      comps,
      "map life",
      Topics.LIFE.toStatmodEntity(Op.ADD, Element.ALL),
      resourceRanges,
      [
        b._explicits("Hale", "of Haleness", _globalMaps()),
        b._explicits("Healthful", "of Health", _globalMaps()),
        b._explicits("Robust", "of Robustness", _globalMaps()),
        b._explicits("Stalwart", "of Stalwart Body", _globalMaps())
      ]
    );

    // ATTRIBUTES

    b.add(
      comps,
      "map strength",
      Topics.STRENGTH.toStatmodEntity(Op.ADD, Element.ALL),
      attrRanges,
      [
        b._explicits("Brutish", "of the Brute", _globalMaps()),
        b._explicits("Canine", "of the Wolf", _globalMaps()),
        b._explicits("Bearish", "of the Bear", _globalMaps()),
        b._explicits("Lionheart", "of the Lion", _globalMaps())
      ]
    );

    b.add(
      comps,
      "map arcana",
      Topics.ARCANA.toStatmodEntity(Op.ADD, Element.ALL),
      attrRanges,
      [
        b._explicits("Studious", "of the Student", _globalMaps()),
        b._explicits("Observant", "of the Goat", _globalMaps()),
        b._explicits("Seercraft", "of the Seer", _globalMaps()),
        b._explicits("Mystical", "of Mysticism", _globalMaps())
      ]
    );

    b.add(
      comps,
      "map dexterity",
      Topics.DEXTERITY.toStatmodEntity(Op.ADD, Element.ALL),
      attrRanges,
      [
        b._explicits("Slick", "of the Mongoose", _globalMaps()),
        b._explicits("Sly", "of the Fox", _globalMaps()),
        b._explicits("Swift", "of the Falcon", _globalMaps()),
        b._explicits("Agile", "of the Panther", _globalMaps())
      ]
    );

    // ATTACK

    b.add(
      comps,
      "map physical attack",
      Topics.ATTACK.toStatmodEntity(Op.ADD, Element.PHYSICAL),
      attackRanges,
      [
        b._explicits("Irate", "of Ire", _globalMaps()),
        b._explicits("Bullish", "of the Bull", _globalMaps()),
        b._explicits("Raging", "of Rage", _globalMaps()),
        b._explicits("Furious", "of Fury", _globalMaps())
      ]
    );

    b.add(
      comps,
      "map fire attack",
      Topics.ATTACK.toStatmodEntity(Op.ADD, Element.FIRE),
      attackRanges,
      [
        b._explicits("Heated", "of Heat", _globalMaps()),
        b._explicits("Smouldering", "of Coals", _globalMaps()),
        b._explicits("Fiery", "of Fire", _globalMaps()),
        b._explicits("Flaming", "of Flames", _globalMaps())
      ]
    );

    b.add(
      comps,
      "map cold attack",
      Topics.ATTACK.toStatmodEntity(Op.ADD, Element.COLD),
      attackRanges,
      [
        b._explicits("Chilled", "of Chills", _globalMaps()),
        b._explicits("Icy", "of Ice", _globalMaps()),
        b._explicits("Cold", "of Cold", _globalMaps()),
        b._explicits("Frosted", "of Frost", _globalMaps())
      ]
    );

    b.add(
      comps,
      "map poison attack",
      Topics.ATTACK.toStatmodEntity(Op.ADD, Element.POISON),
      attackRanges,
      [
        b._explicits("Sickly", "of Sickness", _globalMaps()),
        b._explicits("Poisonous", "of Poison", _globalMaps()),
        b._explicits("Venomous", "of Venom", _globalMaps()),
        b._explicits("Malignant", "of Malignancy", _globalMaps())
      ]
    );

    // RESISTANCE

    b.add(
      comps,
      "map physical resistance",
      Topics.RESISTANCE.toStatmodEntity(Op.ADD, Element.PHYSICAL),
      resistanceRanges,
      [
        b._explicits("Toughened", "of the Oyster", _globalMaps()),
        b._explicits("Sturdy", "of the Lobster", _globalMaps()),
        b._explicits("Reinforced", "of the Nautilus", _globalMaps()),
        b._explicits("Fortified", "of the Tortoise", _globalMaps())
      ]
    );

    b.add(
      comps,
      "map fire resistance",
      Topics.RESISTANCE.toStatmodEntity(Op.ADD, Element.FIRE),
      resistanceRanges,
      [
        b._explicits("Heatproof", "of the Whelpling", _globalMaps()),
        b._explicits("Dousing", "of the Salamander", _globalMaps()),
        b._explicits("Fireproof", "of Fire Warding", _globalMaps()),
        b._explicits("Flamewarded", "of Flame Warding", _globalMaps())
      ]
    );

    b.add(
      comps,
      "map cold resistance",
      Topics.RESISTANCE.toStatmodEntity(Op.ADD, Element.COLD),
      resistanceRanges,
      [
        b._explicits("Insulating", "of the Penguin", _globalMaps()),
        b._explicits("Warming", "of the Walrus", _globalMaps()),
        b._explicits("Coldproof", "of Cold Warding", _globalMaps()),
        b._explicits("Frostwarded", "of Frost Warding", _globalMaps())
      ]
    );

    b.add(
      comps,
      "map poison resistance",
      Topics.RESISTANCE.toStatmodEntity(Op.ADD, Element.POISON),
      resistanceRanges,
      [
        b._explicits("Wholesome", "of the Opossum", _globalMaps()),
        b._explicits("Inoculative", "of the Snake", _globalMaps()),
        b._explicits("Poisonward", "of Poison Warding", _globalMaps()),
        b._explicits("Venomward", "of Venom Warding", _globalMaps())
      ]
    );
  }

  function _globalMaps() internal pure returns (uint256[] memory r) {
    r = new uint256[](3);
    r[0] = MapPrototypes.GLOBAL_BASIC;
    r[1] = MapPrototypes.GLOBAL_RANDOM;
    r[2] = MapPrototypes.GLOBAL_CYCLE_BOSS;
  }

  /// @dev Add a map-specific implicit affix.
  /// Non-standard affix tiers: tier == map level == affix value == requiredIlvl == maxIlvl
  function addMapLevel(
    b.Comps memory comps,
    string memory name,
    string memory label,
    uint32 level
  ) internal {
    TargetLabel[] memory mapLabels = new TargetLabel[](3);
    mapLabels[0] = TargetLabel({
      targetEntity: MapPrototypes.GLOBAL_BASIC,
      label: label
    });
    mapLabels[1] = TargetLabel({
      targetEntity: MapPrototypes.GLOBAL_RANDOM,
      label: label
    });
    mapLabels[2] = TargetLabel({
      targetEntity: MapPrototypes.GLOBAL_CYCLE_BOSS,
      label: label
    });

    b.addOne(
      comps,
      name,
      AffixPrototype({
        tier: level,
        statmodProtoEntity: Topics.LEVEL.toStatmodEntity(Op.BADD, Element.ALL),
        requiredIlvl: level,
        min: level,
        max: level
      }),
      b._implicits(mapLabels),
      level
    );
  }
}
