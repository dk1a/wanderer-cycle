// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

import { Name, NameTableId } from "../codegen/Tables.sol";

library LibInitEquip {
  function spawnEquipmentSlots() internal {
    bytes32 WEAPON = _newSlotEquipment("WEAPON");
    bytes32 SHIELD = _newSlotEquipment("SHIELD");
    bytes32 HAT = _newSlotEquipment("HAT");
    bytes32 CLOTHING = _newSlotEquipment("CLOTHING");
    bytes32 GLOVES = _newSlotEquipment("GLOVES");
    bytes32 PANTS = _newSlotEquipment("PANTS");
    bytes32 BOOTS = _newSlotEquipment("BOOTS");
    bytes32 AMULET = _newSlotEquipment("AMULET");
    bytes32 RING = _newSlotEquipment("RING");
  }

  function _newSlotEquipment(string memory slot) private returns (bytes32 slotEquipment) {
    bytes32 eqptProto = getUniqueEntity();
    Name.set(eqptProto, slot);
  }
}
