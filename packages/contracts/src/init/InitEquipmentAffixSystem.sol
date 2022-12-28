// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";

import { BaseInitAffixSystem, DEFAULT_TIERS } from "./BaseInitAffixSystem.sol";

import { Topics, Op, Element } from "../charstat/Topics.sol";

uint256 constant ID = uint256(keccak256("system.InitEquipmentAffix"));

contract InitEquipmentAffixSystem is BaseInitAffixSystem {
  constructor(IWorld _world, address _components) BaseInitAffixSystem(_world, _components) {}

  function execute(bytes memory) public override onlyOwner returns (bytes memory) {
    Range[DEFAULT_TIERS] memory resourceRanges = [
      Range(1, 4),
      Range(5, 6),
      Range(7, 9),
      Range(10, 12)
    ];

    Range[DEFAULT_TIERS] memory attrRanges = [
      Range(1, 1),
      Range(1, 2),
      Range(2, 3),
      Range(3, 4)
    ];

    Range[DEFAULT_TIERS] memory weaponAttackRanges = [
      Range(1, 4),
      Range(5, 6),
      Range(7, 9),
      Range(10, 12)
    ];

    Range[DEFAULT_TIERS] memory resistanceMinorRanges = [
      Range(1, 3),
      Range(3, 5),
      Range(5, 6),
      Range(6, 7)
    ];

    // RESOURCES

    add(
      "life",
      Topics.LIFE.toStatmodEntity(Op.ADD, Element.ALL),
      resourceRanges,
      [
        _affixes(
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
        _affixes(
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
        _affixes(
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
        _affixes(
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

    add(
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

    add(
      "mana",
      Topics.MANA.toStatmodEntity(Op.ADD, Element.ALL),
      resourceRanges,
      [
        _affixes(
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
        _affixes(
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
        _affixes(
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
        _affixes(
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

    add(
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

    // ATTRIBUTES
    add(
      "strength",
      Topics.STRENGTH.toStatmodEntity(Op.ADD, Element.ALL),
      attrRanges,
      [
        _affixes(
          "Brutish", "of the Brute",
          _attrEquipment(),
          _equipment([
            "Wooden Club",
            "",
            "Headband",
            "",
            "",
            "",
            "",
            "Knucklebone Pendant",
            ""
          ])
        ),
        _affixes(
          "Canine", "of the Wolf",
          _attrEquipment(),
          _equipment([
            "Bronze Mace",
            "",
            "Wolf Pelt",
            "",
            "",
            "",
            "",
            "Wolfclaw Talisman",
            ""
          ])
        ),
        _affixes(
          "Bearish", "of the Bear",
          _attrEquipment(),
          _equipment([
            "Iron Mace",
            "",
            "Ursine Pelt",
            "",
            "",
            "",
            "",
            "Bearclaw Talisman",
            ""
          ])
        ),
        _affixes(
          "Lionheart", "of the Lion",
          _attrEquipment(),
          _equipment([
            "Steel Mace",
            "",
            "Lion Pelt",
            "",
            "",
            "",
            "",
            "Lionclaw Talisman",
            ""
          ])
        )
      ]
    );

    add(
      "arcana",
      Topics.ARCANA.toStatmodEntity(Op.ADD, Element.ALL),
      attrRanges,
      [
        _affixes(
          "Studious", "of the Student",
          _attrEquipment(),
          _equipment([
            "Carved Wand",
            "",
            "Carved Circlet",
            "",
            "",
            "",
            "",
            "Carved Pendant",
            ""
          ])
        ),
        _affixes(
          "Observant", "of the Goat",
          _attrEquipment(),
          _equipment([
            "Goat's Horn",
            "",
            "Goat Skull Mask",
            "",
            "",
            "",
            "",
            "Goat Eye Talisman",
            ""
          ])
        ),
        _affixes(
          "Seercraft", "of the Seer",
          _attrEquipment(),
          _equipment([
            "Bone Wand",
            "",
            "Bone Circlet",
            "",
            "",
            "",
            "",
            "Bone Necklace",
            ""
          ])
        ),
        _affixes(
          "Mystical", "of Mysticism",
          _attrEquipment(),
          _equipment([
            "Mystic Wand",
            "",
            "Mystic Circlet",
            "",
            "",
            "",
            "",
            "Mystic Amulet",
            ""
          ])
        )
      ]
    );

    add(
      "dexterity",
      Topics.DEXTERITY.toStatmodEntity(Op.ADD, Element.ALL),
      attrRanges,
      [
        _affixes(
          "Slick", "of the Mongoose",
          _attrEquipment(),
          _equipment([
            "Skinning Knife",
            "",
            "Skinning Cap",
            "",
            "",
            "",
            "",
            "Rabbit's Foot",
            ""
          ])
        ),
        _affixes(
          "Sly", "of the Fox",
          _attrEquipment(),
          _equipment([
            "Bronze Dagger",
            "",
            "Fox Pelt",
            "",
            "",
            "",
            "",
            "Fox Paw Talisman",
            ""
          ])
        ),
        _affixes(
          "Swift", "of the Falcon",
          _attrEquipment(),
          _equipment([
            "Iron Dagger",
            "",
            "Hunting Hood",
            "",
            "",
            "",
            "",
            "Feather Talisman",
            ""
          ])
        ),
        _affixes(
          "Agile", "of the Panther",
          _attrEquipment(),
          _equipment([
            "Steel Dagger",
            "",
            "Panther Pelt",
            "",
            "",
            "",
            "",
            "Pantherclaw Talisman",
            ""
          ])
        )
      ]
    );

    // ATTACK

    add(
      "weapon base attack",
      Topics.ATTACK.toStatmodEntity(Op.BADD, Element.PHYSICAL),
      weaponAttackRanges,
      [
        _affixes(
          "Burnished", "of Bruising",
          _weapon(),
          _equipment(["Bronze Shortsword", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Polished", "of Striking",
          _weapon(),
          _equipment(["Bronze Falchion", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Honed", "of Harm",
          _weapon(),
          _equipment(["Iron Sword", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Tempered", "of Assault",
          _weapon(),
          _equipment(["Steel Sword", "", "", "", "", "", "", "", ""])
        )
      ]
    );

    add(
      "weapon physical attack",
      Topics.ATTACK.toStatmodEntity(Op.ADD, Element.PHYSICAL),
      weaponAttackRanges,
      [
        _affixes(
          "Irate", "of Ire",
          _weapon(),
          _equipment(["Bronze Hatchet", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Bullish", "of the Bull",
          _weapon(),
          _equipment(["Bronze Axe", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Raging", "of Rage",
          _weapon(),
          _equipment(["Iron Battleaxe", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Furious", "of Fury",
          _weapon(),
          _equipment(["Steel Battlexe", "", "", "", "", "", "", "", ""])
        )
      ]
    );

    add(
      "weapon fire attack",
      Topics.ATTACK.toStatmodEntity(Op.ADD, Element.FIRE),
      weaponAttackRanges,
      [
        _affixes(
          "Heated", "of Heat",
          _weapon(),
          _equipment(["", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Smouldering", "of Coals",
          _weapon(),
          _equipment(["", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Fiery", "of Fire",
          _weapon(),
          _equipment(["", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Flaming", "of Flames",
          _weapon(),
          _equipment(["", "", "", "", "", "", "", "", ""])
        )
      ]
    );

    add(
      "weapon cold attack",
      Topics.ATTACK.toStatmodEntity(Op.ADD, Element.COLD),
      weaponAttackRanges,
      [
        _affixes(
          "Chilled", "of Chills",
          _weapon(),
          _equipment(["", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Icy", "of Ice",
          _weapon(),
          _equipment(["", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Cold", "of Cold",
          _weapon(),
          _equipment(["", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Frosted", "of Frost",
          _weapon(),
          _equipment(["", "", "", "", "", "", "", "", ""])
        )
      ]
    );

    add(
      "weapon poison attack",
      Topics.ATTACK.toStatmodEntity(Op.ADD, Element.POISON),
      weaponAttackRanges,
      [
        _affixes(
          "Sickly", "of Sickness",
          _weapon(),
          _equipment(["", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Poisonous", "of Poison",
          _weapon(),
          _equipment(["", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Venomous", "of Venom",
          _weapon(),
          _equipment(["", "", "", "", "", "", "", "", ""])
        ),
        _affixes(
          "Malignant", "of Malignancy",
          _weapon(),
          _equipment(["", "", "", "", "", "", "", "", ""])
        )
      ]
    );

    // RESISTANCE

    add(
      "physical resistance",
      Topics.RESISTANCE.toStatmodEntity(Op.ADD, Element.PHYSICAL),
      resistanceMinorRanges,
      [
        _affixes(
          "Toughened", "of the Oyster",
          _resEquipment(),
          _equipment([
            "",
            "Banded Shield",
            "Battered Helmet",
            "Rusted Armor",
            "Rusted Bracers",
            "Rusted Legguard",
            "Rusted Boots",
            "",
            ""
          ])
        ),
        _affixes(
          "Sturdy", "of the Lobster",
          _resEquipment(),
          _equipment([
            "",
            "Bronze Shield",
            "Bronze Helmet",
            "Bronze Vest",
            "Bronze Bracers",
            "Bronze Legguards",
            "Bronze Boots",
            "",
            ""
          ])
        ),
        _affixes(
          "Reinforced", "of the Nautilus",
          _resEquipment(),
          _equipment([
            "",
            "Iron Shield",
            "Iron Helmet",
            "Iron Plate",
            "Iron Gauntlets",
            "Iron Legguards",
            "Iron Greaves",
            "",
            ""
          ])
        ),
        _affixes(
          "Fortified", "of the Tortoise",
          _resEquipment(),
          _equipment([
            "",
            "Steel Shield",
            "Steel Helmet",
            "Steel Plate",
            "Steel Gauntlets",
            "Steel Legguards",
            "Steel Greaves",
            "",
            ""
          ])
        )
      ]
    );

    return '';
  }
}