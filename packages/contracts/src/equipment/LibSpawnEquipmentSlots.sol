// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { SlotAllowedBases, Name, OwnedBy } from "../codegen/index.sol";
import { LibInitEquipment, Equipment } from "../init/LibInitEquipment.sol";

type EqptSlot is bytes32;

library LibSpawnEquipmentSlots {
  EqptSlot constant R_HAND = EqptSlot.wrap("R Hand");
  EqptSlot constant L_HAND = EqptSlot.wrap("L HAND");
  EqptSlot constant HEAD = EqptSlot.wrap("HEAD");
  EqptSlot constant BODY = EqptSlot.wrap("BODY");
  EqptSlot constant HANDS = EqptSlot.wrap("HANDS");
  EqptSlot constant LEGS = EqptSlot.wrap("LEGS");
  EqptSlot constant FEET = EqptSlot.wrap("FEET");
  EqptSlot constant NECK = EqptSlot.wrap("NECK");
  EqptSlot constant R_RING = EqptSlot.wrap("R RING");
  EqptSlot constant L_RING = EqptSlot.wrap("L RING");

  function spawnEquipmentSlots(bytes32 ownerEntity) external {
    _newSlotEquipment(
      ownerEntity,
      EqptSlot.unwrap(R_HAND),
      Equipment.unwrap(LibInitEquipment.WEAPON),
      Equipment.unwrap(LibInitEquipment.SHIELD)
    );
    _newSlotEquipment(ownerEntity, EqptSlot.unwrap(L_HAND), Equipment.unwrap(LibInitEquipment.SHIELD));
    _newSlotEquipment(ownerEntity, EqptSlot.unwrap(HEAD), Equipment.unwrap(LibInitEquipment.HAT));
    _newSlotEquipment(ownerEntity, EqptSlot.unwrap(BODY), Equipment.unwrap(LibInitEquipment.CLOTHING));
    _newSlotEquipment(ownerEntity, EqptSlot.unwrap(HANDS), Equipment.unwrap(LibInitEquipment.GLOVES));
    _newSlotEquipment(ownerEntity, EqptSlot.unwrap(LEGS), Equipment.unwrap(LibInitEquipment.PANTS));
    _newSlotEquipment(ownerEntity, EqptSlot.unwrap(FEET), Equipment.unwrap(LibInitEquipment.BOOTS));
    _newSlotEquipment(ownerEntity, EqptSlot.unwrap(NECK), Equipment.unwrap(LibInitEquipment.AMULET));
    _newSlotEquipment(ownerEntity, EqptSlot.unwrap(R_RING), Equipment.unwrap(LibInitEquipment.RING));
    _newSlotEquipment(ownerEntity, EqptSlot.unwrap(L_RING), Equipment.unwrap(LibInitEquipment.RING));
  }

  function _newSlotEquipment(bytes32 ownerEntity, bytes32 slot, bytes32 eqpt) private {
    string memory name = toString(slot);

    Name.set(slot, name);
    OwnedBy.set(slot, ownerEntity);
    SlotAllowedBases.push(slot, eqpt);
  }

  function _newSlotEquipment(bytes32 ownerEntity, bytes32 slot, bytes32 eqpt0, bytes32 eqpt1) private {
    string memory name = toString(slot);

    Name.set(slot, name);
    OwnedBy.set(slot, ownerEntity);
    SlotAllowedBases.push(slot, eqpt0);
    SlotAllowedBases.push(slot, eqpt1);
  }

  function toString(bytes32 slot) public returns (string memory) {
    return string(abi.encodePacked(slot));
  }
}
