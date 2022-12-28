// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";

import { LibLootMint } from "../loot/LibLootMint.sol";
import { AffixPartId } from "../affix/AffixNamingComponent.sol";

import { MapPrototypes } from "../map/MapPrototypes.sol";

uint256 constant ID = uint256(keccak256("system.InitMapsGlobal"));

contract InitMapsBasicGlobalSystem is System {
  uint256 constant internal MAP_PROTO_ENTITY = MapPrototypes.GLOBAL_BASIC;

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory) public override onlyOwner returns (bytes memory) {
    // Hardcoded map level range
    // TODO this should be in a constant somewhere, when you do cycles you'll need this value too
    for (uint256 ilvl = 1; ilvl <= 12; ilvl++) {
      _set(ilvl);
    }

    return '';
  }

  function _set(uint256 ilvl) internal {
    // basic global maps only have the implicit affix
    AffixPartId[] memory affixParts = new AffixPartId[](1);
    affixParts[0] = AffixPartId.IMPLICIT;

    // get a new unique id
    uint256 lootEntity = world.getUniqueEntityId();
    // not really random, there's only 1 implicit per ilvl, it's just easier to reuse this function
    LibLootMint.randomLootMint(
      components,
      affixParts,
      lootEntity,
      MAP_PROTO_ENTITY,
      ilvl,
      0
    );
    // set loot's map prototype
    FromPrototypeComponent fromProtoComp = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));
    fromProtoComp.set(lootEntity, MAP_PROTO_ENTITY);
  }
}