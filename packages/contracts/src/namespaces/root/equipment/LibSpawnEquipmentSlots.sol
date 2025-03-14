// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { Name } from "../codegen/tables/Name.sol";
import { OwnedBy } from "../codegen/tables/OwnedBy.sol";
import { SlotAllowedType } from "../codegen/tables/SlotAllowedType.sol";
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
    SlotAllowedType.set(slotEntity, equipmentType, true);
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
    SlotAllowedType.set(slotEntity, equipmentType0, true);
    SlotAllowedType.set(slotEntity, equipmentType1, true);
  }
}
