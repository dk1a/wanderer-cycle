// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { MapPrototypeComponent, ID as MapPrototypeComponentID } from "../map/MapPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

import { MapPrototypes } from "../map/MapPrototypes.sol";

library LibInitMapPrototype {
  function init(IWorld world) internal {
    IUint256Component components = world.components();

    MapPrototypeComponent protoComp = MapPrototypeComponent(getAddressById(components, MapPrototypeComponentID));
    NameComponent nameComp = NameComponent(getAddressById(components, NameComponentID));

    _set(protoComp, nameComp, MapPrototypes.GLOBAL_BASIC, "Global Basic");
    _set(protoComp, nameComp, MapPrototypes.GLOBAL_RANDOM, "Global Random");
    _set(protoComp, nameComp, MapPrototypes.GLOBAL_CYCLE_BOSS, "Global Cycle Boss");
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
