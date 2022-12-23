// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";
import { Subsystem } from "@latticexyz/solecs/src/Subsystem.sol";

import { EquipmentSlotComponent, ID as EquipmentSlotComponentID } from "./EquipmentSlotComponent.sol";
import { EquipmentSlotAllowedComponent, ID as EquipmentSlotAllowedComponentID } from "./EquipmentSlotAllowedComponent.sol";
import { EquipmentPrototypeComponent, ID as EquipmentPrototypeComponentID } from "./EquipmentPrototypeComponent.sol";
import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";

import { LibEffect } from "../effect/LibEffect.sol";

uint256 constant ID = uint256(keccak256("system.Equipment"));

enum EquipmentAction {
  UNEQUIP,
  EQUIP
}

/**
 * @title Library-like system for other systems that need equipment
 */
contract EquipmentSystem is Subsystem {
  using LibEffect for LibEffect.Self;

  error EquipmentSystem__InvalidEquipmentAction();
  error EquipmentSystem__InvalidEquipmentPrototype();
  error EquipmentSystem__SlotNotAllowedForPrototype();
  error EquipmentSystem__EquipmentEntityAlreadyEquipped();

  constructor(IWorld _world, address _components) Subsystem(_world, _components) {}

  function executeTyped(
    EquipmentAction equipmentAction,
    uint256 equipmentSlot,
    uint256 equipmentEntity,
    uint256 targetEntity
  ) public {
    execute(abi.encode(equipmentAction, equipmentSlot, equipmentEntity, targetEntity));
  }

  /**
   * @notice UNEQUIP/EQUIP target's slot with entity
   * @dev For UNEQUIP equipmentEntity is irrelevant and can just be 0
   */
  function _execute(bytes memory arguments) internal override returns (bytes memory) {
    (
      EquipmentAction equipmentAction,
      uint256 equipmentSlot,
      uint256 equipmentEntity,
      uint256 targetEntity
    ) = abi.decode(arguments, (EquipmentAction, uint256, uint256, uint256));

    EquipmentSlotComponent slotComp = EquipmentSlotComponent(getAddressById(components, EquipmentSlotComponentID));
    // TODO equipmentSlot should be bound to targetEntity, atm they seem too loosely related
    LibEffect.Self memory modelEffect = LibEffect.__construct(components, targetEntity);

    if (equipmentAction == EquipmentAction.UNEQUIP) {
      _unequip(slotComp, modelEffect, equipmentSlot);
    } else if (equipmentAction == EquipmentAction.EQUIP) {
      _equip(slotComp, modelEffect, equipmentSlot, equipmentEntity);
    } else {
      revert EquipmentSystem__InvalidEquipmentAction();
    }

    return '';
  }

  function _unequip(
    EquipmentSlotComponent slotComp,
    LibEffect.Self memory modelEffect,
    uint256 equipmentSlot
  ) internal {
    uint256 equipmentEntity = slotComp.getValue(equipmentSlot);
    slotComp.remove(equipmentSlot);

    modelEffect.remove(equipmentEntity);
  }

  function _equip(
    EquipmentSlotComponent slotComp,
    LibEffect.Self memory modelEffect,
    uint256 equipmentSlot,
    uint256 equipmentEntity
  ) internal {
    // unequip first if slot is occupied (otherwise effects will leak)
    if (slotComp.has(equipmentSlot)) {
      _unequip(slotComp, modelEffect, equipmentSlot);
    }

    // equipmentEntity must have equipment prototype
    // TODO this looks dubious, and also very long
    FromPrototypeComponent fromProtoComp = FromPrototypeComponent(
      getAddressById(components, FromPrototypeComponentID)
    );
    EquipmentPrototypeComponent protoComp = EquipmentPrototypeComponent(
      getAddressById(components, EquipmentPrototypeComponentID)
    );
    uint256 protoEntity = fromProtoComp.getValue(equipmentEntity);
    if (!protoComp.has(protoEntity)) {
      revert EquipmentSystem__InvalidEquipmentPrototype();
    }

    // the slot must allow the equipment prototype
    EquipmentSlotAllowedComponent slotAllowedComp = EquipmentSlotAllowedComponent(
      getAddressById(components, EquipmentSlotAllowedComponentID)
    );
    bool isAllowed = slotAllowedComp.hasItem(equipmentSlot, protoEntity);
    if (!isAllowed) {
      revert EquipmentSystem__SlotNotAllowedForPrototype();
    }

    // entity may not be equipped in 2 slots
    uint256[] memory slotsWithEquipmentEntity = slotComp.getEntitiesWithValue(equipmentEntity);
    if (slotsWithEquipmentEntity.length > 0) {
      revert EquipmentSystem__EquipmentEntityAlreadyEquipped();
    }

    slotComp.set(equipmentSlot, equipmentEntity);

    // reverts if equipmentEntity isn't a valid effectProtoEntity
    // TODO that's good atm because equipment only does effects. But it could do more.
    modelEffect.applyEffect(equipmentEntity);
  }
}