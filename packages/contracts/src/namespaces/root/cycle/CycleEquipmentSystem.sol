// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { OwnedBy } from "../codegen/index.sol";

import { LibEquipment } from "../equipment/LibEquipment.sol";
import { LibLootOwner } from "../loot/LibLootOwner.sol";
import { LibCycle } from "./LibCycle.sol";

/**
 * @dev To equip, target must own both the slot and the equipment.
 * To unequip, target must own only the slot (to account for weird equipment transfer situations).
 */
contract CycleEquipmentSystem is System {
  error CycleEquipmentSystem_NotSlotOwner(bytes32 targetEntity, bytes32 slotEntity);
  error CycleEquipmentSystem_NotEquipmentOwner(bytes32 targetEntity, bytes32 equipmentEntity);

  function _requireOwnedSlot(bytes32 targetEntity, bytes32 slotEntity) internal view {
    if (targetEntity != OwnedBy.get(slotEntity)) {
      revert CycleEquipmentSystem_NotSlotOwner(targetEntity, slotEntity);
    }
  }

  function _requireOwnedEquipment(bytes32 targetEntity, bytes32 equipmentEntity) internal view {
    if (targetEntity != LibLootOwner.simpleOwnerOf(equipmentEntity)) {
      revert CycleEquipmentSystem_NotEquipmentOwner(targetEntity, equipmentEntity);
    }
  }

  function equip(bytes32 wandererEntity, bytes32 slotEntity, bytes32 equipmentEntity) public {
    // Reverts if sender doesn't have permission
    bytes32 cycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);

    _requireOwnedSlot(cycleEntity, slotEntity);
    _requireOwnedEquipment(cycleEntity, equipmentEntity);

    LibEquipment.equip(cycleEntity, slotEntity, equipmentEntity);
  }

  function unequip(bytes32 wandererEntity, bytes32 slotEntity) public {
    // Reverts if sender doesn't have permission
    bytes32 cycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);

    _requireOwnedSlot(cycleEntity, slotEntity);

    LibEquipment.unequip(cycleEntity, slotEntity);
  }
}
