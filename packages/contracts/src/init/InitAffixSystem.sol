// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";

import { BaseInitAffixSystem } from "./BaseInitAffixSystem.sol";

import { Topics, Op, Element } from "../charstat/Topics.sol";

uint256 constant ID = uint256(keccak256("system.InitAffix"));

contract InitAffixSystem is BaseInitAffixSystem {
  constructor(IWorld _world, address _components) BaseInitAffixSystem(_world, _components) {}

  function execute(bytes memory) public override returns (bytes memory) {
    Range[TIER_L] memory resourceRanges = [
      Range(1, 4),
      Range(5, 6),
      Range(7, 9),
      Range(10, 12)
    ];

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

    return '';
  }
}