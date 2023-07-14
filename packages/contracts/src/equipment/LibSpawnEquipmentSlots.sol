// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

import { EqptBase, EqptBaseTableId } from "../codegen/Tables.sol";
import { FromEqptBase, FromEqptBaseTableId } from "../codegen/Tables.sol";
import { SlotAllowedBases, SlotAllowedBasesTableId } from "../codegen/Tables.sol";
import { SlotEquipment, SlotEquipmentTableId } from "../codegen/Tables.sol";

import { Name, NameTableId } from "../codegen/Tables.sol";
import { OwnedBy, OwnedByTableId } from "../codegen/Tables.sol";
import { LibInitEquipment } from "./LibInitEquipment.sol";

library LibSpawnEquipmentSlots {
  string constant R_HAND = "R HAND";
  string constant L_HAND = "L HAND";
  string constant HEAD = "HEAD";
  string constant BODY = "BODY";
  string constant HANDS = "HANDS";
  string constant LEGS = "LEGS";
  string constant FEET = "FEET";
  string constant NECK = "NECK";
  string constant R_RING = "R RING";
  string constant L_RING = "L RING";

  function spawnEquipmentSlots(bytes32 ownerEntity) private {
    _newSlotEquipment(R_HAND, ownerEntity, LibInitEquipment.WEAPON, EquipmentPrototypes.SHIELD);
    _newSlotEquipment(L_HAND, ownerEntity, LibInitEquipment.SHIELD);
    _newSlotEquipment(HEAD, ownerEntity, LibInitEquipment.HAT);
    _newSlotEquipment(BODY, ownerEntity, LibInitEquipment.CLOTHING);
    _newSlotEquipment(HANDS, ownerEntity, LibInitEquipment.GLOVES);
    _newSlotEquipment(LEGS, ownerEntity, LibInitEquipment.PANTS);
    _newSlotEquipment(FEET, ownerEntity, LibInitEquipment.BOOTS);
    _newSlotEquipment(NECK, ownerEntity, LibInitEquipment.AMULET);
    _newSlotEquipment(R_RING, ownerEntity, LibInitEquipment.RING);
    _newSlotEquipment(L_RING, ownerEntity, LibInitEquipment.RING);
  }

  function _newSlotEquipment(
    string memory slot,
    bytes32 ownerEntity,
    string memory eqptBase
  ) private returns (bytes32 slotEntity) {
    slotEntity = getUniqueEntity();
    bytes32 eqptBaseEntity = stringToBytes32(eqptBase);

    Name.set(slotEntity, slot);
    OwnedBy.set(slotEntity, ownerEntity);
    SlotAllowedBases.push(slotEntity, eqptBaseEntity);
  }

  function _newSlotEquipment(
    string memory slot,
    bytes32 ownerEntity,
    string memory eqptBase0,
    string memory eqptBase1
  ) private returns (bytes32 slotEntity) {
    slotEntity = getUniqueEntity();
    bytes32 eqptBaseEntity0 = stringToBytes32(eqptBase0);
    bytes32 eqptBaseEntity1 = stringToBytes32(eqptBase1);

    Name.set(slotEntity, slot);
    OwnedBy.set(slotEntity, ownerEntity);
    SlotAllowedBases.push(eqptProto, slotNameEntity0);
    SlotAllowedBases.push(eqptProto, slotNameEntity1);
  }

  function stringToBytes32(string memory str) private pure returns (bytes32 result) {
    bytes memory strBytes = bytes(str);
    require(strBytes.length <= 32, "String too long");

    assembly {
      result := mload(add(strBytes, 32))
    }
  }
}
