// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { Name, OwnedBy, SlotAllowedTypes } from "../codegen/index.sol";
import { EquipmentType, EquipmentTypes } from "./EquipmentType.sol";

library LibSpawnEquipmentSlots {
  function spawnEquipmentSlots(bytes32 ownerEntity) external {
    _newSlotEntity(ownerEntity, "R Hand", EquipmentTypes.WEAPON, EquipmentTypes.SHIELD);
    // TODO dual wielding to conditionally let L Hand use weapon too
    _newSlotEntity(ownerEntity, "L Hand", EquipmentTypes.SHIELD);
    _newSlotEntity(ownerEntity, "Head", EquipmentTypes.HAT);
    _newSlotEntity(ownerEntity, "Body", EquipmentTypes.CLOTHING);
    _newSlotEntity(ownerEntity, "Hands", EquipmentTypes.GLOVES);
    _newSlotEntity(ownerEntity, "Legs", EquipmentTypes.PANTS);
    _newSlotEntity(ownerEntity, "Feet", EquipmentTypes.BOOTS);
    _newSlotEntity(ownerEntity, "Neck", EquipmentTypes.AMULET);
    _newSlotEntity(ownerEntity, "R Ring", EquipmentTypes.RING);
    _newSlotEntity(ownerEntity, "L Ring", EquipmentTypes.RING);
  }

  function _newSlotEntity(bytes32 ownerEntity, string memory name, EquipmentType equipmentType) private {
    bytes32 slotEntity = getUniqueEntity();

    Name.set(slotEntity, name);
    OwnedBy.set(slotEntity, ownerEntity);
    SlotAllowedTypes.push(slotEntity, EquipmentType.unwrap(equipmentType));
  }

  function _newSlotEntity(
    bytes32 ownerEntity,
    string memory name,
    EquipmentType equipmentType0,
    EquipmentType equipmentType1
  ) private {
    bytes32 slotEntity = getUniqueEntity();

    Name.set(slotEntity, name);
    OwnedBy.set(slotEntity, ownerEntity);
    SlotAllowedTypes.push(slotEntity, EquipmentType.unwrap(equipmentType0));
    SlotAllowedTypes.push(slotEntity, EquipmentType.unwrap(equipmentType1));
  }
}
