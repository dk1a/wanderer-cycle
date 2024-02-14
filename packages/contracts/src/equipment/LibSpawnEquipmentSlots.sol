// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

//import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
//import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";
//
//import { SlotAllowedBases, Name, NameTableId, OwnedBy} from "../codegen/index.sol";
//
//import { LibInitEquipment } from "../init/LibInitEquipment.sol";
//
//library LibSpawnEquipmentSlots {
//  string constant R_HAND = "R HAND";
//  string constant L_HAND = "L HAND";
//  string constant HEAD = "HEAD";
//  string constant BODY = "BODY";
//  string constant HANDS = "HANDS";
//  string constant LEGS = "LEGS";
//  string constant FEET = "FEET";
//  string constant NECK = "NECK";
//  string constant R_RING = "R RING";
//  string constant L_RING = "L RING";
//
//  function spawnEquipmentSlots(bytes32 ownerEntity) external {
//    bytes32 weapon = LibInitEquipment.getEquipmentId("WEAPON");
//    bytes32 shield = LibInitEquipment.getEquipmentId("SHIELD");
//    bytes32 hat = LibInitEquipment.getEquipmentId("HAT");
//    bytes32 clothing = LibInitEquipment.getEquipmentId("CLOTHING");
//    bytes32 gloves = LibInitEquipment.getEquipmentId("GLOVES");
//    bytes32 pants = LibInitEquipment.getEquipmentId("PANTS");
//    bytes32 boots = LibInitEquipment.getEquipmentId("BOOTS");
//    bytes32 amulet = LibInitEquipment.getEquipmentId("AMULET");
//    bytes32 ring = LibInitEquipment.getEquipmentId("RING");
//
//    _newSlotEquipment(ownerEntity, R_HAND, weapon, shield);
//    _newSlotEquipment(ownerEntity, L_HAND, shield);
//    _newSlotEquipment(ownerEntity, HEAD, hat);
//    _newSlotEquipment(ownerEntity, BODY, clothing);
//    _newSlotEquipment(ownerEntity, HANDS, gloves);
//    _newSlotEquipment(ownerEntity, LEGS, pants);
//    _newSlotEquipment(ownerEntity, FEET, boots);
//    _newSlotEquipment(ownerEntity, NECK, amulet);
//    _newSlotEquipment(ownerEntity, R_RING, ring);
//    _newSlotEquipment(ownerEntity, L_RING, ring);
//  }
//
//  function _newSlotEquipment(
//    bytes32 ownerEntity,
//    string memory slot,
//    bytes32 eqptBaseId
//  ) private returns (bytes32 slotEntity) {
//    slotEntity = getUniqueEntity();
//
//    Name.set(slotEntity, slot);
//    OwnedBy.set(slotEntity, ownerEntity);
//    SlotAllowedBases.push(slotEntity, eqptBaseId);
//  }
//
//  function _newSlotEquipment(
//    bytes32 ownerEntity,
//    string memory slot,
//    bytes32 eqptBaseId0,
//    bytes32 eqptBaseId1
//  ) private returns (bytes32 slotEntity) {
//    slotEntity = getUniqueEntity();
//
//    Name.set(slotEntity, slot);
//    OwnedBy.set(slotEntity, ownerEntity);
//    SlotAllowedBases.push(slotEntity, eqptBaseId0);
//    SlotAllowedBases.push(slotEntity, eqptBaseId1);
//  }
//
//  function stringToBytes32(string memory str) private pure returns (bytes32 result) {
//    bytes memory strBytes = bytes(str);
//    require(strBytes.length <= 32, "String too long");
//
//    assembly {
//      result := mload(add(strBytes, 32))
//    }
//  }
//
//  function getSlotByName(string memory slotName) private view returns (bytes32) {
//    bytes32[] memory slotKeys = getKeysWithValue(NameTableId, bytes(slotName));
//    if (slotKeys.length == 0) {
//      revert("slotEntity not found");
//    }
//    return slotKeys[0];
//  }
//}
