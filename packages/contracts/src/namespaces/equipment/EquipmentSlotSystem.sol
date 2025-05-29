// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SmartObjectFramework } from "../evefrontier/SmartObjectFramework.sol";

import { commonSystem } from "../common/codegen/systems/CommonSystemLib.sol";
import { LibSOFClass } from "../common/LibSOFClass.sol";
import { SlotAllowedType } from "./codegen/tables/SlotAllowedType.sol";
import { EquipmentType, EquipmentTypes } from "./EquipmentType.sol";

contract EquipmentSlotSystem is SmartObjectFramework {
  error EquipmentSlotSystem_InvalidEquipmentType(EquipmentType equipmentType);

  function createEquipmentSlot(
    bytes32 ownerEntity,
    string memory name,
    EquipmentType equipmentType
  ) public returns (bytes32 slotEntity) {
    EquipmentType[] memory equipmentTypes = new EquipmentType[](1);
    equipmentTypes[0] = equipmentType;
    return createEquipmentSlot(ownerEntity, name, equipmentTypes);
  }

  function createEquipmentSlot(
    bytes32 ownerEntity,
    string memory name,
    EquipmentType[] memory equipmentTypes
  ) public context returns (bytes32 slotEntity) {
    _requireEntityLeaf(ownerEntity);

    slotEntity = LibSOFClass.instantiate("equipment_slot");

    // TODO naming restrictions?
    commonSystem.setName(slotEntity, name);
    commonSystem.setOwnedBy(slotEntity, ownerEntity);

    for (uint256 i; i < equipmentTypes.length; i++) {
      EquipmentType equipmentType = equipmentTypes[i];
      if (EquipmentType.unwrap(equipmentType) == bytes32(0)) {
        revert EquipmentSlotSystem_InvalidEquipmentType(equipmentType);
      }
      SlotAllowedType.set(slotEntity, equipmentType, true);
    }
  }
}
