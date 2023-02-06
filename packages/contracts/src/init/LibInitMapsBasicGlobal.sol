// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";

import { LibLootMint } from "../loot/LibLootMint.sol";
import { AffixPartId } from "../affix/AffixNamingComponent.sol";

import { MapPrototypes } from "../map/MapPrototypes.sol";

library LibInitMapsBasicGlobal {
  uint256 internal constant MAP_PROTO_ENTITY = MapPrototypes.GLOBAL_BASIC;

  function init(IWorld world) internal {
    IUint256Component components = world.components();

    // Hardcoded map level range
    // TODO this should be in a constant somewhere, when you do cycles you'll need this value too
    for (uint32 ilvl = 1; ilvl <= 12; ilvl++) {
      _set(world, components, ilvl);
    }
  }

  function _set(IWorld world, IUint256Component components, uint32 ilvl) private {
    // basic global maps only have the implicit affix
    AffixPartId[] memory affixParts = new AffixPartId[](1);
    affixParts[0] = AffixPartId.IMPLICIT;

    // get a new unique id
    uint256 lootEntity = world.getUniqueEntityId();
    // not really random, there's only 1 implicit per ilvl, it's just easier to reuse this function
    LibLootMint.randomLootMint(components, affixParts, lootEntity, MAP_PROTO_ENTITY, ilvl, 0);
    // set loot's map prototype
    FromPrototypeComponent fromProtoComp = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));
    fromProtoComp.set(lootEntity, MAP_PROTO_ENTITY);
  }
}
