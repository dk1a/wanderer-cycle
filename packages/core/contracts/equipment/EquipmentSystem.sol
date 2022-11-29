// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

// TODO SystemFacet is a crutch
import { SystemFacet } from "@dk1a/solecslib/contracts/mud/SystemFacet.sol";
import { SystemStorage } from "@dk1a/solecslib/contracts/mud/SystemStorage.sol";

import { EquipmentComponent, ID as EquipmentComponentID } from "./EquipmentComponent.sol";
import { EquipmentSlotToTypesComponent, ID as EquipmentSlotToTypesComponentID } from "./EquipmentSlotToTypesComponent.sol";
import { EquipmentTypeComponent, ID as EquipmentTypeComponentID } from "./EquipmentTypeComponent.sol";

import { LibEffect } from "../effect/LibEffect.sol";

uint256 constant ID = uint256(keccak256("system.Equipment"));

enum EquipmentAction {
  UNEQUIP,
  EQUIP
}

/**
 * @title Library-like system for other systems that need equipment
 */
contract EquipmentSystem is SystemFacet {
  using LibEffect for LibEffect.Self;

  error EquipmentSystem__InvalidEquipmentAction();
  error EquipmentSystem__InvalidEquipmentType();
  error EquipmentSystem__InvalidEquipmentSlotForType();
  error EquipmentSystem__EquipmentEntityAlreadyEquipped();
  error EquipmentSystem__EquipmentSlotOccupied();

  constructor(IWorld _world, address _components) {
    __SystemFacet_init(_world, _components);
  }

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
  function execute(bytes memory arguments) public onlyWriter returns (bytes memory) {
    (
      EquipmentAction equipmentAction,
      uint256 equipmentSlot,
      uint256 equipmentEntity,
      uint256 targetEntity
    ) = abi.decode(arguments, (EquipmentAction, uint256, uint256, uint256));

    EquipmentComponent equipmentComp
      = EquipmentComponent(getAddressById(SystemStorage.layout().components, EquipmentComponentID));
    // TODO equipmentSlot should be bound to targetEntity, atm they seem too loosely related
    LibEffect.Self memory modelEffect = LibEffect.__construct(SystemStorage.layout().components, targetEntity);

    if (equipmentAction == EquipmentAction.UNEQUIP) {
      _unequip(equipmentComp, modelEffect, equipmentSlot);
    } else if (equipmentAction == EquipmentAction.EQUIP) {
      _equip(equipmentComp, modelEffect, equipmentSlot, equipmentEntity);
    } else {
      revert EquipmentSystem__InvalidEquipmentAction();
    }

    return '';
  }

  function _unequip(
    EquipmentComponent equipmentComp,
    LibEffect.Self memory modelEffect,
    uint256 equipmentSlot
  ) internal {
    uint256 equipmentEntity = equipmentComp.getValue(equipmentSlot);
    equipmentComp.remove(equipmentSlot);

    modelEffect.remove(equipmentEntity);
  }

  function _equip(
    EquipmentComponent equipmentComp,
    LibEffect.Self memory modelEffect,
    uint256 equipmentSlot,
    uint256 equipmentEntity
  ) internal {
    // unequip first if slot is occupied (otherwise effects will leak)
    if (equipmentComp.has(equipmentSlot)) {
      _unequip(equipmentComp, modelEffect, equipmentSlot);
    }

    // get equipment type
    EquipmentTypeComponent typeComp = EquipmentTypeComponent(
      getAddressById(SystemStorage.layout().components, EquipmentTypeComponentID)
    );
    if (!typeComp.has(equipmentEntity)) {
      revert EquipmentSystem__InvalidEquipmentType();
    }
    uint256 equipmentType = typeComp.getValue(equipmentEntity);

    // check slots for type, different slots allow different types to be equipped
    EquipmentSlotToTypesComponent slotToTypeComp = EquipmentSlotToTypesComponent(
      getAddressById(SystemStorage.layout().components, EquipmentSlotToTypesComponentID)
    );
    bool isTypeAllowed = slotToTypeComp.hasItem(equipmentSlot, equipmentType);
    if (!isTypeAllowed) {
      revert EquipmentSystem__InvalidEquipmentSlotForType();
    }

    // entity may not be equipped in 2 slots
    uint256[] memory slotsWithEquipmentEntity = equipmentComp.getEntitiesWithValue(equipmentEntity);
    if (slotsWithEquipmentEntity.length > 0) {
      revert EquipmentSystem__EquipmentEntityAlreadyEquipped();
    }

    equipmentComp.set(equipmentSlot, equipmentEntity);

    // reverts if equipmentEntity isn't a valid effectProtoEntity
    // TODO that's good atm because equipment only does effects. But it could do more.
    modelEffect.applyEffect(equipmentEntity);
  }
}