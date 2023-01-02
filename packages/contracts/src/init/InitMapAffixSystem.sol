// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";

import { BaseInitAffixSystem, DEFAULT_TIERS, AffixPrototype } from "./BaseInitAffixSystem.sol";

import { Topics, Op, Element } from "../charstat/Topics.sol";
import { MapPrototypes } from "../map/MapPrototypes.sol";

uint256 constant ID = uint256(keccak256("system.InitMapAffix"));

contract InitMapAffixSystem is BaseInitAffixSystem {
  constructor(IWorld _world, address _components) BaseInitAffixSystem(_world, _components) {}

  function execute(bytes memory) public override onlyOwner returns (bytes memory) {
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
      Topics.LIFE.toStatmodEntity(Op.ADD, Element.ALL),
      resourceRanges,
      [
        _explicits("Hale", "of Haleness", _globalMaps()),
        _explicits("Healthful", "of Health", _globalMaps()),
        _explicits("Robust", "of Robustness", _globalMaps()),
        _explicits("Stalwart", "of Stalwart Body", _globalMaps())
      ]
    );

    // ATTRIBUTES

    add(
      "map strength",
      Topics.STRENGTH.toStatmodEntity(Op.ADD, Element.ALL),
      attrRanges,
      [
        _explicits("Brutish", "of the Brute", _globalMaps()),
        _explicits("Canine", "of the Wolf", _globalMaps()),
        _explicits("Bearish", "of the Bear", _globalMaps()),
        _explicits("Lionheart", "of the Lion", _globalMaps())
      ]
    );

    add(
      "map arcana",
      Topics.ARCANA.toStatmodEntity(Op.ADD, Element.ALL),
      attrRanges,
      [
        _explicits("Studious", "of the Student", _globalMaps()),
        _explicits("Observant", "of the Goat", _globalMaps()),
        _explicits("Seercraft", "of the Seer", _globalMaps()),
        _explicits("Mystical", "of Mysticism", _globalMaps())
      ]
    );

    add(
      "map dexterity",
      Topics.DEXTERITY.toStatmodEntity(Op.ADD, Element.ALL),
      attrRanges,
      [
        _explicits("Slick", "of the Mongoose", _globalMaps()),
        _explicits("Sly", "of the Fox", _globalMaps()),
        _explicits("Swift", "of the Falcon", _globalMaps()),
        _explicits("Agile", "of the Panther", _globalMaps())
      ]
    );

    // ATTACK

    add(
      "map physical attack",
      Topics.ATTACK.toStatmodEntity(Op.ADD, Element.PHYSICAL),
      attackRanges,
      [
        _explicits("Irate", "of Ire", _globalMaps()),
        _explicits("Bullish", "of the Bull", _globalMaps()),
        _explicits("Raging", "of Rage", _globalMaps()),
        _explicits("Furious", "of Fury", _globalMaps())
      ]
    );

    add(
      "map fire attack",
      Topics.ATTACK.toStatmodEntity(Op.ADD, Element.FIRE),
      attackRanges,
      [
        _explicits("Heated", "of Heat", _globalMaps()),
        _explicits("Smouldering", "of Coals", _globalMaps()),
        _explicits("Fiery", "of Fire", _globalMaps()),
        _explicits("Flaming", "of Flames", _globalMaps())
      ]
    );

    add(
      "map cold attack",
      Topics.ATTACK.toStatmodEntity(Op.ADD, Element.COLD),
      attackRanges,
      [
        _explicits("Chilled", "of Chills", _globalMaps()),
        _explicits("Icy", "of Ice", _globalMaps()),
        _explicits("Cold", "of Cold", _globalMaps()),
        _explicits("Frosted", "of Frost", _globalMaps())
      ]
    );

    add(
      "map poison attack",
      Topics.ATTACK.toStatmodEntity(Op.ADD, Element.POISON),
      attackRanges,
      [
        _explicits("Sickly", "of Sickness", _globalMaps()),
        _explicits("Poisonous", "of Poison", _globalMaps()),
        _explicits("Venomous", "of Venom", _globalMaps()),
        _explicits("Malignant", "of Malignancy", _globalMaps())
      ]
    );

    // RESISTANCE

    add(
      "map physical resistance",
      Topics.RESISTANCE.toStatmodEntity(Op.ADD, Element.PHYSICAL),
      resistanceRanges,
      [
        _explicits("Toughened", "of the Oyster", _globalMaps()),
        _explicits("Sturdy", "of the Lobster", _globalMaps()),
        _explicits("Reinforced", "of the Nautilus", _globalMaps()),
        _explicits("Fortified", "of the Tortoise", _globalMaps())
      ]
    );

    add(
      "map fire resistance",
      Topics.RESISTANCE.toStatmodEntity(Op.ADD, Element.FIRE),
      resistanceRanges,
      [
        _explicits("Heatproof", "of the Whelpling", _globalMaps()),
        _explicits("Dousing", "of the Salamander", _globalMaps()),
        _explicits("Fireproof", "of Fire Warding", _globalMaps()),
        _explicits("Flamewarded", "of Flame Warding", _globalMaps())
      ]
    );

    add(
      "map cold resistance",
      Topics.RESISTANCE.toStatmodEntity(Op.ADD, Element.COLD),
      resistanceRanges,
      [
        _explicits("Insulating", "of the Penguin", _globalMaps()),
        _explicits("Warming", "of the Walrus", _globalMaps()),
        _explicits("Coldproof", "of Cold Warding", _globalMaps()),
        _explicits("Frostwarded", "of Frost Warding", _globalMaps())
      ]
    );

    add(
      "map poison resistance",
      Topics.RESISTANCE.toStatmodEntity(Op.ADD, Element.POISON),
      resistanceRanges,
      [
        _explicits("Wholesome", "of the Opossum", _globalMaps()),
        _explicits("Inoculative", "of the Snake", _globalMaps()),
        _explicits("Poisonward", "of Poison Warding", _globalMaps()),
        _explicits("Venomward", "of Venom Warding", _globalMaps())
      ]
    );

    return '';
  }

  function _globalMaps() internal pure returns (uint256[] memory r) {
    r = new uint256[](1);
    r[0] = MapPrototypes.GLOBAL_BASIC;
  }

  /// @dev Add a map-specific implicit affix.
  /// Non-standard affix tiers: tier == map level == affix value == requiredIlvl == maxIlvl
  function addMapLevel(
    string memory name,
    string memory label,
    uint256 level
  ) internal {
    TargetLabel[] memory mapLabels = new TargetLabel[](1);
    mapLabels[0] = TargetLabel({
      targetEntity: MapPrototypes.GLOBAL_BASIC,
      label: label
    });

    addOne(
      name,
      AffixPrototype({
        tier: level,
        statmodProtoEntity: Topics.LEVEL.toStatmodEntity(Op.BADD, Element.ALL),
        requiredIlvl: level,
        min: level,
        max: level
      }),
      _implicits(mapLabels),
      level
    );
  }
}