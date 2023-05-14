// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

import { LibLootMint } from "../loot/LibLootMint.sol";
import { LibPickAffixes } from "../affix/LibPickAffixes.sol";
import { AffixPartId } from "../affix/AffixNamingComponent.sol";

import { MapPrototypes } from "../map/MapPrototypes.sol";

library LibInitMapsBoss {
  struct ManualAffix {
    AffixPartId affixPart;
    string name;
    uint32 tier;
  }

  function init(IWorld world) internal {
    IUint256Component components = world.components();

    // 1
    _setBoss(
      world,
      components,
      "Dire Rabbit",
      1,
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 1", 1),
        ManualAffix(AffixPartId.PREFIX, "map life", 1),
        ManualAffix(AffixPartId.PREFIX, "map strength", 1),
        ManualAffix(AffixPartId.SUFFIX, "map physical resistance", 1),
        ManualAffix(AffixPartId.SUFFIX, "map dexterity", 1)
      ]
    );
    // 2
    _setBoss(
      world,
      components,
      "Cultist Invoker",
      2,
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 2", 2),
        ManualAffix(AffixPartId.PREFIX, "map life", 1),
        ManualAffix(AffixPartId.PREFIX, "map fire attack", 1),
        ManualAffix(AffixPartId.SUFFIX, "map fire resistance", 1),
        ManualAffix(AffixPartId.SUFFIX, "map dexterity", 1)
      ]
    );
    // 3
    _setBoss(
      world,
      components,
      "Goblin Wolfrider",
      3,
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 3", 3),
        ManualAffix(AffixPartId.PREFIX, "map life", 1),
        ManualAffix(AffixPartId.PREFIX, "map physical attack", 1),
        ManualAffix(AffixPartId.SUFFIX, "map dexterity", 4),
        ManualAffix(AffixPartId.SUFFIX, "map poison attack", 1)
      ]
    );
    // 4
    _setBoss(
      world,
      components,
      "Hill Giant",
      4,
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 4", 4),
        ManualAffix(AffixPartId.PREFIX, "map life", 3),
        ManualAffix(AffixPartId.PREFIX, "map strength", 3),
        ManualAffix(AffixPartId.SUFFIX, "map physical attack", 2),
        ManualAffix(AffixPartId.SUFFIX, "map physical resistance", 1)
      ]
    );
    // 5
    _setBoss(
      world,
      components,
      "Goblin Shaman",
      5,
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 5", 5),
        ManualAffix(AffixPartId.PREFIX, "map life", 3),
        ManualAffix(AffixPartId.PREFIX, "map arcana", 4),
        ManualAffix(AffixPartId.SUFFIX, "map fire attack", 1),
        ManualAffix(AffixPartId.SUFFIX, "map dexterity", 3)
      ]
    );
    // 6
    _setBoss(
      world,
      components,
      "Vilewood Treant",
      6,
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 6", 6),
        ManualAffix(AffixPartId.PREFIX, "map strength", 3),
        ManualAffix(AffixPartId.PREFIX, "map poison attack", 2),
        ManualAffix(AffixPartId.PREFIX, "map physical resistance", 2),
        ManualAffix(AffixPartId.SUFFIX, "map poison resistance", 3),
        ManualAffix(AffixPartId.SUFFIX, "map fire resistance", 1),
        ManualAffix(AffixPartId.SUFFIX, "map cold resistance", 2)
      ]
    );
    // 7
    _setBoss(
      world,
      components,
      "Orc Warlord",
      7,
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 7", 7),
        ManualAffix(AffixPartId.PREFIX, "map strength", 4),
        ManualAffix(AffixPartId.PREFIX, "map physical attack", 4),
        ManualAffix(AffixPartId.SUFFIX, "map physical resistance", 3),
        ManualAffix(AffixPartId.SUFFIX, "map poison resistance", 1)
      ]
    );
    // 8
    _setBoss(
      world,
      components,
      "Grand Toad",
      8,
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 8", 8),
        ManualAffix(AffixPartId.PREFIX, "map life", 4),
        ManualAffix(AffixPartId.PREFIX, "map strength", 3),
        ManualAffix(AffixPartId.SUFFIX, "map poison attack", 3),
        ManualAffix(AffixPartId.SUFFIX, "map dexterity", 3)
      ]
    );
    // 9
    _setBoss(
      world,
      components,
      "Chimera",
      9,
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 9", 9),
        ManualAffix(AffixPartId.PREFIX, "map life", 4),
        ManualAffix(AffixPartId.PREFIX, "map dexterity", 4),
        ManualAffix(AffixPartId.SUFFIX, "map poison attack", 4),
        ManualAffix(AffixPartId.SUFFIX, "map strength", 3)
      ]
    );
    // 10
    _setBoss(
      world,
      components,
      "Ice Giant",
      10,
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 10", 10),
        ManualAffix(AffixPartId.PREFIX, "map life", 4),
        ManualAffix(AffixPartId.PREFIX, "map strength", 4),
        ManualAffix(AffixPartId.PREFIX, "map physical attack", 3),
        ManualAffix(AffixPartId.SUFFIX, "map cold attack", 2),
        ManualAffix(AffixPartId.SUFFIX, "map physical resistance", 2),
        ManualAffix(AffixPartId.SUFFIX, "map cold resistance", 3)
      ]
    );
    // 11
    _setBoss(
      world,
      components,
      "Fire Drake",
      11,
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 11", 11),
        ManualAffix(AffixPartId.PREFIX, "map life", 4),
        ManualAffix(AffixPartId.PREFIX, "map strength", 4),
        ManualAffix(AffixPartId.PREFIX, "map dexterity", 2),
        ManualAffix(AffixPartId.SUFFIX, "map fire attack", 4),
        ManualAffix(AffixPartId.SUFFIX, "map fire resistance", 4),
        ManualAffix(AffixPartId.SUFFIX, "map physical resistance", 2)
      ]
    );
    // 12
    _setBoss(
      world,
      components,
      "The Shadow",
      12,
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 12", 12),
        ManualAffix(AffixPartId.PREFIX, "map cold resistance", 4),
        ManualAffix(AffixPartId.PREFIX, "map poison resistance", 4),
        ManualAffix(AffixPartId.PREFIX, "map physical resistance", 3),
        ManualAffix(AffixPartId.PREFIX, "map fire resistance", 3),
        ManualAffix(AffixPartId.SUFFIX, "map poison attack", 4),
        ManualAffix(AffixPartId.SUFFIX, "map arcana", 4),
        ManualAffix(AffixPartId.SUFFIX, "map dexterity", 4),
        ManualAffix(AffixPartId.SUFFIX, "map life", 3)
      ]
    );
  }

  function _setBoss(
    IWorld world,
    IUint256Component components,
    string memory name,
    uint32 ilvl,
    ManualAffix[5] memory manualAffixesStatic
  ) private {
    ManualAffix[] memory manualAffixes = new ManualAffix[](manualAffixesStatic.length);
    for (uint256 i; i < manualAffixesStatic.length; i++) {
      manualAffixes[i] = manualAffixesStatic[i];
    }
    _setBoss(world, components, name, ilvl, manualAffixes);
  }

  function _setBoss(
    IWorld world,
    IUint256Component components,
    string memory name,
    uint32 ilvl,
    ManualAffix[7] memory manualAffixesStatic
  ) private {
    ManualAffix[] memory manualAffixes = new ManualAffix[](manualAffixesStatic.length);
    for (uint256 i; i < manualAffixesStatic.length; i++) {
      manualAffixes[i] = manualAffixesStatic[i];
    }
    _setBoss(world, components, name, ilvl, manualAffixes);
  }

  function _setBoss(
    IWorld world,
    IUint256Component components,
    string memory name,
    uint32 ilvl,
    ManualAffix[9] memory manualAffixesStatic
  ) private {
    ManualAffix[] memory manualAffixes = new ManualAffix[](manualAffixesStatic.length);
    for (uint256 i; i < manualAffixesStatic.length; i++) {
      manualAffixes[i] = manualAffixesStatic[i];
    }
    _setBoss(world, components, name, ilvl, manualAffixes);
  }

  function _setBoss(
    IWorld world,
    IUint256Component components,
    string memory name,
    uint32 ilvl,
    ManualAffix[] memory manualAffixes
  ) private {
    AffixPartId[] memory affixParts = new AffixPartId[](manualAffixes.length);
    string[] memory names = new string[](manualAffixes.length);
    uint32[] memory tiers = new uint32[](manualAffixes.length);

    for (uint256 i; i < manualAffixes.length; i++) {
      affixParts[i] = manualAffixes[i].affixPart;
      names[i] = manualAffixes[i].name;
      tiers[i] = manualAffixes[i].tier;
    }

    (
      uint256[] memory statmodProtoEntities,
      uint256[] memory affixProtoEntities,
      uint32[] memory affixValues
    ) = LibPickAffixes.manuallyPickAffixesMax(components, names, tiers);

    // get a new unique id
    uint256 lootEntity = world.getUniqueEntityId();
    LibLootMint.lootMint(
      components,
      lootEntity,
      ilvl,
      affixParts,
      statmodProtoEntities,
      affixProtoEntities,
      affixValues
    );
    // set loot's map prototype
    FromPrototypeComponent fromProtoComp = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));
    fromProtoComp.set(lootEntity, MapPrototypes.GLOBAL_CYCLE_BOSS);
    // set name
    NameComponent(getAddressById(components, NameComponentID)).set(lootEntity, name);
  }
}
