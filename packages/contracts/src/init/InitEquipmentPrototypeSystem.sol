// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import {
  EquipmentPrototypeComponent,
  ID as EquipmentPrototypeComponentID
} from "../equipment/EquipmentPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

import { EquipmentPrototypes } from "../equipment/EquipmentPrototypes.sol";

uint256 constant ID = uint256(keccak256("system.InitEquipmentPrototype"));

// Inititalize equipment prototypes
// Sets of equipment protoEntities are used to determine what can be equipped in slots
contract InitEquipmentPrototypeSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory) public override onlyOwner returns (bytes memory) {
    EquipmentPrototypeComponent protoComp = EquipmentPrototypeComponent(
      getAddressById(world.components(), EquipmentPrototypeComponentID)
    );
    NameComponent nameComp = NameComponent(
      getAddressById(world.components(), NameComponentID)
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

    return '';
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