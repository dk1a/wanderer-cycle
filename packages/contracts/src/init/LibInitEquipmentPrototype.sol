// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import {
  EquipmentPrototypeComponent,
  ID as EquipmentPrototypeComponentID
} from "../equipment/EquipmentPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

import { EquipmentPrototypes } from "../equipment/EquipmentPrototypes.sol";

// Inititalize equipment prototypes
// Sets of equipment protoEntities are used to determine what can be equipped in slots
library LibInitEquipmentPrototype {
  function init(IWorld world) internal {
    IUint256Component components = world.components();

    EquipmentPrototypeComponent protoComp = EquipmentPrototypeComponent(
      getAddressById(components, EquipmentPrototypeComponentID)
    );
    NameComponent nameComp = NameComponent(
      getAddressById(components, NameComponentID)
    );
 
    _set(protoComp, nameComp, EquipmentPrototypes.WEAPON,   "Weapon");
    _set(protoComp, nameComp, EquipmentPrototypes.SHIELD,   "Shield");
    _set(protoComp, nameComp, EquipmentPrototypes.HAT,      "Hat");
    _set(protoComp, nameComp, EquipmentPrototypes.CLOTHING, "Clothing");
    _set(protoComp, nameComp, EquipmentPrototypes.GLOVES,   "Gloves");
    _set(protoComp, nameComp, EquipmentPrototypes.PANTS,    "Pants");
    _set(protoComp, nameComp, EquipmentPrototypes.BOOTS,    "Boots");
    _set(protoComp, nameComp, EquipmentPrototypes.AMULET,   "Amulet");
    _set(protoComp, nameComp, EquipmentPrototypes.RING,     "Ring");
  }

  function _set(
    EquipmentPrototypeComponent protoComp,
    NameComponent nameComp,
    uint256 protoEntity,
    string memory name
  ) internal {
    protoComp.set(protoEntity);
    nameComp.set(protoEntity, name);
  }
}