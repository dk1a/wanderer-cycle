// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { commonSystem } from "../../common/codegen/systems/CommonSystemLib.sol";

import { LibPickAffix } from "../../affix/LibPickAffix.sol";
import { LibLootMint } from "../../loot/LibLootMint.sol";
import { AffixPartId } from "../../../codegen/common.sol";
import { MapTypeComponent } from "../../map/codegen/tables/MapTypeComponent.sol";

import { MapTypes } from "../../map/MapType.sol";
import { AffixAvailabilityTargetId, MapAffixAvailabilityTargetIds } from "../../map/MapAffixAvailabilityTargetIds.sol";

library LibInitMapsBoss {
  struct ManualAffix {
    AffixPartId affixPart;
    string name;
    uint32 tier;
  }

  function init() internal {
    // 1
    _setBoss(
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

  function _setBoss(string memory name, uint32 ilvl, ManualAffix[5] memory manualAffixesStatic) private {
    ManualAffix[] memory manualAffixes = new ManualAffix[](manualAffixesStatic.length);
    for (uint256 i; i < manualAffixesStatic.length; i++) {
      manualAffixes[i] = manualAffixesStatic[i];
    }
    _setBoss(name, ilvl, manualAffixes);
  }

  function _setBoss(string memory name, uint32 ilvl, ManualAffix[7] memory manualAffixesStatic) private {
    ManualAffix[] memory manualAffixes = new ManualAffix[](manualAffixesStatic.length);
    for (uint256 i; i < manualAffixesStatic.length; i++) {
      manualAffixes[i] = manualAffixesStatic[i];
    }
    _setBoss(name, ilvl, manualAffixes);
  }

  function _setBoss(string memory name, uint32 ilvl, ManualAffix[9] memory manualAffixesStatic) private {
    ManualAffix[] memory manualAffixes = new ManualAffix[](manualAffixesStatic.length);
    for (uint256 i; i < manualAffixesStatic.length; i++) {
      manualAffixes[i] = manualAffixesStatic[i];
    }
    _setBoss(name, ilvl, manualAffixes);
  }

  function _setBoss(string memory name, uint32 ilvl, ManualAffix[] memory manualAffixes) private {
    AffixPartId[] memory affixParts = new AffixPartId[](manualAffixes.length);
    string[] memory names = new string[](manualAffixes.length);
    uint32[] memory tiers = new uint32[](manualAffixes.length);

    for (uint256 i; i < manualAffixes.length; i++) {
      affixParts[i] = manualAffixes[i].affixPart;
      names[i] = manualAffixes[i].name;
      tiers[i] = manualAffixes[i].tier;
    }

    (bytes32[] memory statmodEntities, bytes32[] memory affixProtoEntities, uint32[] memory affixValues) = LibPickAffix
      .manuallyPickAffixesMax(names, tiers);

    // get a new unique id
    bytes32 lootEntity = getUniqueEntity();
    AffixAvailabilityTargetId targetId = MapAffixAvailabilityTargetIds.RANDOM_MAP;
    LibLootMint.lootMint(lootEntity, targetId, ilvl, affixParts, statmodEntities, affixProtoEntities, affixValues);

    // mark this loot as a map by setting its MapType
    MapTypeComponent.set(lootEntity, MapTypes.CYCLE_BOSS);
    // set name
    commonSystem.setName(lootEntity, name);
  }
}
