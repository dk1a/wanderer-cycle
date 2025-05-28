// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { AffixAvailabilityTargetId, LibAffixParts as b } from "../../affix/LibAffixParts.sol";
import { LibSOFClass } from "../../common/LibSOFClass.sol";
import { LibLootMint } from "../../loot/LibLootMint.sol";
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
    // global basic maps only have the implicit affix
    AffixPartId[] memory affixParts = new AffixPartId[](1);
    affixParts[0] = AffixPartId.IMPLICIT;

    lootEntity = LibSOFClass.instantiate("map", deployer);
    // not really random, there's only 1 implicit per ilvl, it's just easier to reuse this function
    LibLootMint.randomLootMint(affixParts, lootEntity, MapAffixAvailabilityTargetIds.RANDOM_MAP, ilvl, 0);

    // mark this loot as a map by setting its MapType
    MapTypeComponent.set(lootEntity, MapTypes.BASIC);
  }

  function makeRandom(address deployer, uint32 ilvl, uint256 randomness) internal returns (bytes32 lootEntity) {
    AffixPartId[] memory affixParts = new AffixPartId[](3);
    affixParts[0] = AffixPartId.IMPLICIT;
    affixParts[1] = AffixPartId.SUFFIX;
    affixParts[2] = AffixPartId.PREFIX;

    lootEntity = LibSOFClass.instantiate("map", deployer);
    LibLootMint.randomLootMint(affixParts, lootEntity, MapAffixAvailabilityTargetIds.RANDOM_MAP, ilvl, randomness);

    // mark this loot as a map by setting its MapType
    MapTypeComponent.set(lootEntity, MapTypes.RANDOM);
  }
}
