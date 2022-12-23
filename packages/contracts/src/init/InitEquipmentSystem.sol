// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import {
  getEquipmentProtoEntity,
  EquipmentPrototypeComponent,
  ID as EquipmentPrototypeComponentID
} from "../equipment/EquipmentPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

uint256 constant ID = uint256(keccak256("system.InitEquipment"));

// Inititalize equipment prototypes
// Sets of equipment protoEntities are used to determine what can be equipped in slots
contract InitEquipmentSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory) public override onlyOwner returns (bytes memory) {
    EquipmentPrototypeComponent protoComp = EquipmentPrototypeComponent(
      getAddressById(world.components(), EquipmentPrototypeComponentID)
    );
    NameComponent nameComp = NameComponent(
      getAddressById(world.components(), NameComponentID)
    );
 
    _set(protoComp, nameComp, "Weapon");
    _set(protoComp, nameComp, "Shield");
    _set(protoComp, nameComp, "Hat");
    _set(protoComp, nameComp, "Clothing");
    _set(protoComp, nameComp, "Gloves");
    _set(protoComp, nameComp, "Pants");
    _set(protoComp, nameComp, "Boots");
    _set(protoComp, nameComp, "Amulet");
    _set(protoComp, nameComp, "Ring");

    return '';
  }

  function _set(
    EquipmentPrototypeComponent protoComp,
    NameComponent nameComp,
    string memory name
  ) internal {
    uint256 protoEntity = getEquipmentProtoEntity(name);
    protoComp.set(protoEntity);
    nameComp.set(protoEntity, name);
  }
}