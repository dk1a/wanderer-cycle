// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import {
  MapPrototypeComponent,
  ID as MapPrototypeComponentID
} from "../map/MapPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

import { MapPrototypes } from "../map/MapPrototypes.sol";

uint256 constant ID = uint256(keccak256("system.InitMapPrototype"));

contract InitMapPrototypeSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory) public override onlyOwner returns (bytes memory) {
    MapPrototypeComponent protoComp = MapPrototypeComponent(
      getAddressById(world.components(), MapPrototypeComponentID)
    );
    NameComponent nameComp = NameComponent(
      getAddressById(world.components(), NameComponentID)
    );
 
    _set(protoComp, nameComp, MapPrototypes.GLOBAL_BASIC, "Global Basic");

    return '';
  }

  function _set(
    MapPrototypeComponent protoComp,
    NameComponent nameComp,
    uint256 protoEntity,
    string memory name
  ) internal {
    protoComp.set(protoEntity);
    nameComp.set(protoEntity, name);
  }
}