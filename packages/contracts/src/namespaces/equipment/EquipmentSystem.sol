// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { effectSystem } from "../effect/codegen/systems/EffectSystemLib.sol";

import { LibSpawnEquipmentSlots } from "./LibSpawnEquipmentSlots.sol";

import { EquipmentType } from "./EquipmentType.sol";
import { EquipmentTypeComponent } from "./codegen/tables/EquipmentTypeComponent.sol";
import { SlotAllowedType } from "./codegen/tables/SlotAllowedType.sol";
import { SlotEquipment } from "./codegen/tables/SlotEquipment.sol";
import { Idx_SlotEquipment_EquipmentEntity } from "./codegen/idxs/Idx_SlotEquipment_EquipmentEntity.sol";

/**
 * @title Equip/unequip equipment to slots.
 * @dev Equipment are entities that have `EquipmentTypeComponent` set.
 * Slots are entities defined by allowed equipment types via `SlotAllowedType`.
 * Targets are entities that own both equipment and slots, targets have equipment effects applied to them.
 * (this structure allows characters to have different/dynamic sets of limbs).
 */
contract EquipmentSystem is System {
  error EquipmentSystem_InvalidEquipmentType(bytes32 equipmentEntity);
  error EquipmentSystem_SlotNotAllowedForType(bytes32 slotEntity, EquipmentType equipmentType, bytes32 equipmentEntity);
  error EquipmentSystem_EquipmentEntityAlreadyEquipped(bytes32 equipmentEntity);

  function unequip(bytes32 targetEntity, bytes32 slotEntity) public {
    bytes32 equipmentEntity = SlotEquipment.get(slotEntity);
    effectSystem.remove(targetEntity, equipmentEntity);

    SlotEquipment.deleteRecord(slotEntity);
  }

  function equip(bytes32 targetEntity, bytes32 slotEntity, bytes32 equipmentEntity) public {
    // Unequip first if slot is occupied (otherwise effects will leak)
    if (SlotEquipment.get(slotEntity) != bytes32(0)) {
      unequip(targetEntity, slotEntity);
    }

    // Equipment entity must have EquipmentType set
    EquipmentType equipmentType = EquipmentTypeComponent.get(equipmentEntity);
    if (EquipmentType.unwrap(equipmentType) == bytes32(0)) {
      revert EquipmentSystem_InvalidEquipmentType(equipmentEntity);
    }

    // The slot must allow the equipment type
    bool isAllowed = SlotAllowedType.get(slotEntity, equipmentType);
    if (!isAllowed) {
      revert EquipmentSystem_SlotNotAllowedForType(slotEntity, equipmentType, equipmentEntity);
    }

    // Equipment must not be already equipped in a slot
    if (Idx_SlotEquipment_EquipmentEntity.length(equipmentEntity) > 0) {
      revert EquipmentSystem_EquipmentEntityAlreadyEquipped(equipmentEntity);
    }

    SlotEquipment.set(slotEntity, equipmentEntity);

    // Reverts if equipmentEntity doesn't have an EffectTemplate
    // TODO that's good atm because equipment only does effects, but it could do more
    effectSystem.applyEffect(targetEntity, equipmentEntity);
  }

  function spawnEquipmentSlots(bytes32 ownerEntity) public {
    LibSpawnEquipmentSlots.spawnEquipmentSlots(ownerEntity);
  }
}
