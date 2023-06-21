// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

import { EqptBase, EqptBaseTableId } from "../codegen/Tables.sol";
import { FromEqptBase, FromEqptBaseTableId } from "../codegen/Tables.sol";
import { SlotAllowedBases, SlotAllowedBasesTableId } from "../codegen/Tables.sol";
import { SlotEquipment, SlotEquipmentTableId } from "../codegen/Tables.sol";

import { Name, NameTableId } from "../codegen/Tables.sol";
import { OwnedBy, OwnedByTableId } from "../codegen/Tables.sol";

library LibSpawnEquipmentSlots {
  function spawnEquipmentSlots(bytes32 ownerEntity) internal {
    bytes32 WEAPON = _newSlotEquipment(ownerEntity, "WEAPON");
    bytes32 SHIELD = _newSlotEquipment(ownerEntity, "SHIELD");
    bytes32 HAT = _newSlotEquipment(ownerEntity, "HAT");
    bytes32 CLOTHING = _newSlotEquipment(ownerEntity, "CLOTHING");
    bytes32 GLOVES = _newSlotEquipment(ownerEntity, "GLOVES");
    bytes32 PANTS = _newSlotEquipment(ownerEntity, "PANTS");
    bytes32 BOOTS = _newSlotEquipment(ownerEntity, "BOOTS");
    bytes32 AMULET = _newSlotEquipment(ownerEntity, "AMULET");
    bytes32 RING = _newSlotEquipment(ownerEntity, "RING");

    _newSlotEntity(ownerEntity, "R Hand", WEAPON, SHIELD);
    // TODO dual wielding to conditionally let L Hand use weapon too
    _newSlotEntity(ownerEntity, "L Hand", SHIELD);
    _newSlotEntity(ownerEntity, "Head", HAT);
    _newSlotEntity(ownerEntity, "Body", CLOTHING);
    _newSlotEntity(ownerEntity, "Hands", GLOVES);
    _newSlotEntity(ownerEntity, "Legs", PANTS);
    _newSlotEntity(ownerEntity, "Feet", BOOTS);
    _newSlotEntity(ownerEntity, "Neck", AMULET);
    _newSlotEntity(ownerEntity, "R Ring", RING);
    _newSlotEntity(ownerEntity, "L Ring", RING);
  }

  function _newSlotEquipment(bytes32 ownerEntity, string memory slot) private returns (bytes32 slotEquipment) {
    bytes32 eqptProto = getUniqueEntity();
    Name.set(eqptProto, slot);
    OwnedBy.set(eqptProto, ownerEntity);
  }

  function _newSlotEntity(
    bytes32 ownerEntity,
    string memory name,
    bytes32 equipmentProtoEntity0
  ) private returns (bytes32 slotEntity) {
    slotEntity = getUniqueEntity();
    Name.set(slotEntity, name);
    OwnedBy.set(slotEntity, ownerEntity);
    SlotAllowedBases.push(slotEntity, equipmentProtoEntity0);
  }

  function _newSlotEntity(
    bytes32 ownerEntity,
    string memory name,
    bytes32 equipmentProtoEntity0,
    bytes32 equipmentProtoEntity1
  ) private returns (bytes32 slotEntity) {
    slotEntity = getUniqueEntity();
    Name.set(slotEntity, name);
    OwnedBy.set(slotEntity, ownerEntity);
    SlotAllowedBases.push(slotEntity, equipmentProtoEntity0);
    SlotAllowedBases.push(slotEntity, equipmentProtoEntity1);
  }
}
