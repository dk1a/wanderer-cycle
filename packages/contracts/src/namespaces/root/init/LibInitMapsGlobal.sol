// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { affixSystem } from "../../affix/codegen/systems/AffixSystemLib.sol";
import { AffixAvailabilityTargetId, LibAffixParts as b } from "../../affix/LibAffixParts.sol";
import { LibSOFClass } from "../../common/LibSOFClass.sol";
import { LibLootMint } from "../../loot/LibLootMint.sol";
import { mapLevelToAffixTier } from "../../map/MapLevelToAffixTier.sol";
import { AffixPartId } from "../../../codegen/common.sol";
import { MapTypeComponent } from "../../map/codegen/tables/MapTypeComponent.sol";

import { MapTypes } from "../../map/MapType.sol";
import { MapAffixAvailabilityTargetIds } from "../../map/MapAffixAvailabilityTargetIds.sol";

library LibInitMapsGlobal {
  function init(address deployer) internal {
    // Hardcoded map level range
    // TODO this should be in a constant somewhere, when you do cycles you'll need this value too
    for (uint32 ilvl = 1; ilvl <= 12; ilvl++) {
      makeBasic(deployer, ilvl);
    }
    // TODO put this into a system to generate new ones each day
    for (uint32 ilvl = 2; ilvl <= 10; ilvl += 4) {
      uint256 randomness = uint256(keccak256(abi.encode("global random map", ilvl, blockhash(block.number))));
      makeRandom(deployer, ilvl, randomness);
    }
  }

  function makeBasic(address deployer, uint32 ilvl) internal returns (bytes32 lootEntity) {
    lootEntity = LibSOFClass.instantiate("map", deployer);
    // global basic maps only have the implicit affix
    LibLootMint.lootMint(
      lootEntity,
      MapAffixAvailabilityTargetIds.RANDOM_MAP,
      1,
      _instantiateMapLevelImplicitAffixes(ilvl)
    );

    // mark this loot as a map by setting its MapType
    MapTypeComponent.set(lootEntity, MapTypes.BASIC);
  }

  function makeRandom(address deployer, uint32 ilvl, uint256 randomness) internal returns (bytes32 lootEntity) {
    AffixPartId[] memory affixParts = new AffixPartId[](2);
    affixParts[0] = AffixPartId.SUFFIX;
    affixParts[1] = AffixPartId.PREFIX;

    uint32 affixTier = mapLevelToAffixTier(ilvl);

    lootEntity = LibSOFClass.instantiate("map", deployer);
    LibLootMint.randomLootMint(
      _instantiateMapLevelImplicitAffixes(ilvl),
      affixParts,
      lootEntity,
      MapAffixAvailabilityTargetIds.RANDOM_MAP,
      affixTier,
      randomness
    );

    // mark this loot as a map by setting its MapType
    MapTypeComponent.set(lootEntity, MapTypes.RANDOM);
  }

  function _instantiateMapLevelImplicitAffixes(uint32 ilvl) internal returns (bytes32[] memory affixEntities) {
    AffixPartId[] memory affixPartIds = new AffixPartId[](1);
    affixPartIds[0] = AffixPartId.IMPLICIT;

    string[] memory names = new string[](1);
    names[0] = string.concat("map level ", Strings.toString(ilvl));

    uint32[] memory affixTiers = new uint32[](1);
    affixTiers[0] = mapLevelToAffixTier(ilvl);

    affixEntities = affixSystem.instantiateManualAffixesMax(affixPartIds, names, affixTiers);
  }
}
