// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { OwnedBy } from "../codegen/index.sol";

//import { EquipmentSystem, EquipmentAction } from "../equipment/EquipmentSubSystem.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibLootOwner } from "../loot/LibLootOwner.sol";

contract CycleEquipmentSystem is System {
  error CycleEquipmentSystem__NotSlotOwner();
  error CycleEquipmentSystem__NotEquipmentOwner();

  function manageEquipmentCycle(bytes memory args) public returns (bytes memory) {
    //    (EquipmentAction equipmentAction, bytes32 wandererEntity, bytes32 equipmentSlot, bytes32 equipmentEntity) = abi
    //      .decode(args, (EquipmentAction, bytes32, bytes32, bytes32));

    //    // reverts if sender doesn't have permission
    //    bytes32 cycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);
    //
    //    // the caller must own the equipment slot
    //    if (cycleEntity != OwnedBy.get(equipmentSlot)) {
    //      revert CycleEquipmentSystem__NotSlotOwner();
    //    }
    //    // and the equipment
    //    // TODO allow the entity which has `equipmentEntity` equipped to unequip it without owning it
    //    if (cycleEntity != LibLootOwner.ownerOf(components, equipmentEntity)) {
    //      revert CycleEquipmentSystem__NotEquipmentOwner();
    //    }
    //
    //    EquipmentSubSystem.executeTyped(equipmentAction, equipmentSlot, equipmentEntity);

    return "";
  }
}
