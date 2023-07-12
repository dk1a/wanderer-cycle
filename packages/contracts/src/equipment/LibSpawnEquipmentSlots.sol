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
  string[] constant equipmentSlots = [
    "R Hand",
    "L Hand",
    "Head",
    "Body",
    "Hands",
    "Legs",
    "Feet",
    "Neck",
    "R Ring",
    "L Ring"
  ];
  string constant R_HAND = "R Hand";
  string constant L_HAND = "L Hand";
  string constant HEAD = "Head";
  string constant BODY = "Body";
  string constant HANDS = "Hands";
  string constant LEGS = "Legs";
  string constant FEET = "Feet";
  string constant NECK = "Neck";
  string constant R_RING = "R Ring";
  string constant L_RING = "L Ring";

  function spawnEquipmentSlots() private {}

  function _newSlotEquipment(string memory slot) private returns (bytes32 slotEquipment) {
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
