// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { LibLootMint } from "../loot/LibLootMint.sol";
import { AffixPartId } from "../../../codegen/common.sol";
import { MapTypeComponent, MapTypeAffixAvailability } from "../codegen/index.sol";

import { MapTypes } from "../map/MapType.sol";

library LibInitMapsGlobal {
  function init() internal {
    bytes32 affixAvailabilityEntity = MapTypeAffixAvailability.get("random_map");

    // Hardcoded map level range
    // TODO this should be in a constant somewhere, when you do cycles you'll need this value too
    for (uint32 ilvl = 1; ilvl <= 12; ilvl++) {
      _setBasic(affixAvailabilityEntity, ilvl);
    }
    // TODO put this into a system to generate new ones each day
    for (uint32 ilvl = 2; ilvl <= 10; ilvl += 4) {
      uint256 randomness = uint256(keccak256(abi.encode("global random map", ilvl, blockhash(block.number))));
      _setRandom(affixAvailabilityEntity, ilvl, randomness);
    }
  }

  function _setBasic(bytes32 affixAvailabilityEntity, uint32 ilvl) private {
    // global basic maps only have the implicit affix
    AffixPartId[] memory affixParts = new AffixPartId[](1);
    affixParts[0] = AffixPartId.IMPLICIT;

    // get a new unique id
    bytes32 lootEntity = getUniqueEntity();
    // not really random, there's only 1 implicit per ilvl, it's just easier to reuse this function
    LibLootMint.randomLootMint(affixParts, lootEntity, affixAvailabilityEntity, ilvl, 0);

    // mark this loot as a map by setting its MapType
    MapTypeComponent.set(lootEntity, MapTypes.BASIC);
  }

  function _setRandom(bytes32 affixAvailabilityEntity, uint32 ilvl, uint256 randomness) private {
    AffixPartId[] memory affixParts = new AffixPartId[](3);
    affixParts[0] = AffixPartId.IMPLICIT;
    affixParts[1] = AffixPartId.SUFFIX;
    affixParts[2] = AffixPartId.PREFIX;

    // get a new unique id
    bytes32 lootEntity = getUniqueEntity();
    LibLootMint.randomLootMint(affixParts, lootEntity, affixAvailabilityEntity, ilvl, randomness);

    // mark this loot as a map by setting its MapType
    MapTypeComponent.set(lootEntity, MapTypes.RANDOM);
  }
}
