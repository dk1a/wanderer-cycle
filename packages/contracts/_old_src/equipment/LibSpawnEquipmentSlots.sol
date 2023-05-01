// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";
import { OwnedByComponent, ID as OwnedByComponentID } from "../common/OwnedByComponent.sol";
import { EquipmentSlotAllowedComponent, ID as EquipmentSlotAllowedComponentID } from "./EquipmentSlotAllowedComponent.sol";

import { EquipmentPrototypes } from "./EquipmentPrototypes.sol";

library LibSpawnEquipmentSlots {
  struct Self {
    IWorld world;
    NameComponent name;
    OwnedByComponent ownedBy;
    EquipmentSlotAllowedComponent slotAllowed;
    uint256 ownerEntity;
  }

  function spawnEquipmentSlots(IWorld world, uint256 ownerEntity) internal {
    IUint256Component components = world.components();
    Self memory self = Self({
      world: world,
      name: NameComponent(getAddressById(components, NameComponentID)),
      ownedBy: OwnedByComponent(getAddressById(components, OwnedByComponentID)),
      slotAllowed: EquipmentSlotAllowedComponent(getAddressById(components, EquipmentSlotAllowedComponentID)),
      ownerEntity: ownerEntity
    });

    _newSlotEntity(self, "R Hand", EquipmentPrototypes.WEAPON, EquipmentPrototypes.SHIELD);
    // TODO dual wielding to conditionally let L Hand use weapon too
    _newSlotEntity(self, "L Hand", EquipmentPrototypes.SHIELD);
    _newSlotEntity(self, "Head", EquipmentPrototypes.HAT);
    _newSlotEntity(self, "Body", EquipmentPrototypes.CLOTHING);
    _newSlotEntity(self, "Hands", EquipmentPrototypes.GLOVES);
    _newSlotEntity(self, "Legs", EquipmentPrototypes.PANTS);
    _newSlotEntity(self, "Feet", EquipmentPrototypes.BOOTS);
    _newSlotEntity(self, "Neck", EquipmentPrototypes.AMULET);
    _newSlotEntity(self, "R Ring", EquipmentPrototypes.RING);
    _newSlotEntity(self, "L Ring", EquipmentPrototypes.RING);
  }

  function _newSlotEntity(
    Self memory self,
    string memory name,
    uint256 equipmentProtoEntity0
  ) private returns (uint256 slotEntity) {
    slotEntity = self.world.getUniqueEntityId();
    self.name.set(slotEntity, name);
    self.ownedBy.set(slotEntity, self.ownerEntity);
    self.slotAllowed.addItem(slotEntity, equipmentProtoEntity0);
  }

  function _newSlotEntity(
    Self memory self,
    string memory name,
    uint256 equipmentProtoEntity0,
    uint256 equipmentProtoEntity1
  ) private returns (uint256 slotEntity) {
    slotEntity = self.world.getUniqueEntityId();
    self.name.set(slotEntity, name);
    self.ownedBy.set(slotEntity, self.ownerEntity);
    self.slotAllowed.addItem(slotEntity, equipmentProtoEntity0);
    self.slotAllowed.addItem(slotEntity, equipmentProtoEntity1);
  }
}
