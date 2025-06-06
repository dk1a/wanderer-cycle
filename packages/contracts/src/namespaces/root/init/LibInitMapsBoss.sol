// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { commonSystem } from "../../common/codegen/systems/CommonSystemLib.sol";
import { affixSystem } from "../../affix/codegen/systems/AffixSystemLib.sol";

import { LibSOFClass } from "../../common/LibSOFClass.sol";
import { LibLootMint } from "../../loot/LibLootMint.sol";
import { mapLevelToAffixTier } from "../../map/MapLevelToAffixTier.sol";
import { AffixPartId } from "../../../codegen/common.sol";
import { MapTypeComponent } from "../../map/codegen/tables/MapTypeComponent.sol";
import { RequiredBossMaps } from "../../cycle/codegen/tables/RequiredBossMaps.sol";

import { MapTypes } from "../../map/MapType.sol";
import { AffixAvailabilityTargetId, MapAffixAvailabilityTargetIds } from "../../map/MapAffixAvailabilityTargetIds.sol";

library LibInitMapsBoss {
  struct ManualAffix {
    AffixPartId affixPart;
    string name;
    uint32 tier;
  }

  function init(address deployer) internal {
    // 1
    _setBoss(
      deployer,
      "Dire Rabbit",
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
      deployer,
      "Cultist Invoker",
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 2", 1),
        ManualAffix(AffixPartId.PREFIX, "map life", 1),
        ManualAffix(AffixPartId.PREFIX, "map fire attack", 1),
        ManualAffix(AffixPartId.SUFFIX, "map fire resistance", 1),
        ManualAffix(AffixPartId.SUFFIX, "map dexterity", 1)
      ]
    );
    // 3
    _setBoss(
      deployer,
      "Goblin Wolfrider",
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 3", 1),
        ManualAffix(AffixPartId.PREFIX, "map life", 1),
        ManualAffix(AffixPartId.PREFIX, "map physical attack", 1),
        ManualAffix(AffixPartId.SUFFIX, "map dexterity", 4),
        ManualAffix(AffixPartId.SUFFIX, "map poison attack", 1)
      ]
    );
    // 4
    _setBoss(
      deployer,
      "Hill Giant",
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 4", 1),
        ManualAffix(AffixPartId.PREFIX, "map life", 3),
        ManualAffix(AffixPartId.PREFIX, "map strength", 3),
        ManualAffix(AffixPartId.SUFFIX, "map physical attack", 2),
        ManualAffix(AffixPartId.SUFFIX, "map physical resistance", 1)
      ]
    );
    // 5
    _setBoss(
      deployer,
      "Goblin Shaman",
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 5", 2),
        ManualAffix(AffixPartId.PREFIX, "map life", 3),
        ManualAffix(AffixPartId.PREFIX, "map arcana", 4),
        ManualAffix(AffixPartId.SUFFIX, "map fire attack", 1),
        ManualAffix(AffixPartId.SUFFIX, "map dexterity", 3)
      ]
    );
    // 6
    _setBoss(
      deployer,
      "Vilewood Treant",
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 6", 2),
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
      deployer,
      "Orc Warlord",
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 7", 2),
        ManualAffix(AffixPartId.PREFIX, "map strength", 4),
        ManualAffix(AffixPartId.PREFIX, "map physical attack", 4),
        ManualAffix(AffixPartId.SUFFIX, "map physical resistance", 3),
        ManualAffix(AffixPartId.SUFFIX, "map poison resistance", 1)
      ]
    );
    // 8
    _setBoss(
      deployer,
      "Grand Toad",
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 8", 2),
        ManualAffix(AffixPartId.PREFIX, "map life", 4),
        ManualAffix(AffixPartId.PREFIX, "map strength", 3),
        ManualAffix(AffixPartId.SUFFIX, "map poison attack", 3),
        ManualAffix(AffixPartId.SUFFIX, "map dexterity", 3)
      ]
    );
    // 9
    _setBoss(
      deployer,
      "Chimera",
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 9", 3),
        ManualAffix(AffixPartId.PREFIX, "map life", 4),
        ManualAffix(AffixPartId.PREFIX, "map dexterity", 4),
        ManualAffix(AffixPartId.SUFFIX, "map poison attack", 4),
        ManualAffix(AffixPartId.SUFFIX, "map strength", 3)
      ]
    );
    // 10
    _setBoss(
      deployer,
      "Ice Giant",
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 10", 3),
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
      deployer,
      "Fire Drake",
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 11", 3),
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
      deployer,
      "The Shadow",
      [
        ManualAffix(AffixPartId.IMPLICIT, "map level 12", 3),
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

  function _setBoss(address deployer, string memory name, ManualAffix[5] memory manualAffixesStatic) private {
    ManualAffix[] memory manualAffixes = new ManualAffix[](manualAffixesStatic.length);
    for (uint256 i; i < manualAffixesStatic.length; i++) {
      manualAffixes[i] = manualAffixesStatic[i];
    }
    _setBoss(deployer, name, manualAffixes);
  }

  function _setBoss(address deployer, string memory name, ManualAffix[7] memory manualAffixesStatic) private {
    ManualAffix[] memory manualAffixes = new ManualAffix[](manualAffixesStatic.length);
    for (uint256 i; i < manualAffixesStatic.length; i++) {
      manualAffixes[i] = manualAffixesStatic[i];
    }
    _setBoss(deployer, name, manualAffixes);
  }

  function _setBoss(address deployer, string memory name, ManualAffix[9] memory manualAffixesStatic) private {
    ManualAffix[] memory manualAffixes = new ManualAffix[](manualAffixesStatic.length);
    for (uint256 i; i < manualAffixesStatic.length; i++) {
      manualAffixes[i] = manualAffixesStatic[i];
    }
    _setBoss(deployer, name, manualAffixes);
  }

  function _setBoss(address deployer, string memory name, ManualAffix[] memory manualAffixes) private {
    AffixPartId[] memory affixParts = new AffixPartId[](manualAffixes.length);
    string[] memory names = new string[](manualAffixes.length);
    uint32[] memory tiers = new uint32[](manualAffixes.length);

    for (uint256 i; i < manualAffixes.length; i++) {
      affixParts[i] = manualAffixes[i].affixPart;
      names[i] = manualAffixes[i].name;
      tiers[i] = manualAffixes[i].tier;
    }

    bytes32[] memory affixEntities = affixSystem.instantiateManualAffixesMax(affixParts, names, tiers);

    // get a new unique id
    bytes32 lootEntity = LibSOFClass.instantiate("map", deployer);
    AffixAvailabilityTargetId targetId = MapAffixAvailabilityTargetIds.RANDOM_MAP;
    LibLootMint.lootMint(lootEntity, targetId, 1, affixEntities);

    // mark this loot as a map by setting its MapType
    MapTypeComponent.set(lootEntity, MapTypes.CYCLE_BOSS);
    // set name
    commonSystem.setName(lootEntity, name);
    // append it to the list of required boss maps
    RequiredBossMaps.push(lootEntity);
  }
}
