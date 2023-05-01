// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";

import { LibLootMint } from "../loot/LibLootMint.sol";
import { AffixPartId } from "../affix/AffixNamingComponent.sol";

import { MapPrototypes } from "../map/MapPrototypes.sol";

library LibInitMapsGlobal {
  function init(IWorld world) internal {
    IUint256Component components = world.components();

    // Hardcoded map level range
    // TODO this should be in a constant somewhere, when you do cycles you'll need this value too
    for (uint32 ilvl = 1; ilvl <= 12; ilvl++) {
      _setBasic(world, components, ilvl);
    }
    // TODO put this into a system to generate new ones each day
    for (uint32 ilvl = 2; ilvl <= 10; ilvl += 4) {
      uint256 randomness = uint256(keccak256(abi.encode("global random map", ilvl, blockhash(block.number))));
      _setRandom(world, components, ilvl, randomness);
    }
  }

  function _setBasic(IWorld world, IUint256Component components, uint32 ilvl) private {
    // global basic maps only have the implicit affix
    AffixPartId[] memory affixParts = new AffixPartId[](1);
    affixParts[0] = AffixPartId.IMPLICIT;

    // get a new unique id
    uint256 lootEntity = world.getUniqueEntityId();
    // not really random, there's only 1 implicit per ilvl, it's just easier to reuse this function
    LibLootMint.randomLootMint(components, affixParts, lootEntity, MapPrototypes.GLOBAL_BASIC, ilvl, 0);
    // set loot's map prototype
    FromPrototypeComponent fromProtoComp = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));
    fromProtoComp.set(lootEntity, MapPrototypes.GLOBAL_BASIC);
  }

  function _setRandom(IWorld world, IUint256Component components, uint32 ilvl, uint256 randomness) private {
    AffixPartId[] memory affixParts = new AffixPartId[](3);
    affixParts[0] = AffixPartId.IMPLICIT;
    affixParts[1] = AffixPartId.SUFFIX;
    affixParts[2] = AffixPartId.PREFIX;

    // get a new unique id
    uint256 lootEntity = world.getUniqueEntityId();
    LibLootMint.randomLootMint(components, affixParts, lootEntity, MapPrototypes.GLOBAL_RANDOM, ilvl, randomness);
    // set loot's map prototype
    FromPrototypeComponent fromProtoComp = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));
    fromProtoComp.set(lootEntity, MapPrototypes.GLOBAL_RANDOM);
  }
}
