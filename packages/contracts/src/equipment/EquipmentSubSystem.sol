// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";
import { Subsystem } from "@dk1a/solecslib/contracts/mud/Subsystem.sol";

import { EquipmentSlotComponent, ID as EquipmentSlotComponentID } from "./EquipmentSlotComponent.sol";
import { EquipmentSlotAllowedComponent, ID as EquipmentSlotAllowedComponentID } from "./EquipmentSlotAllowedComponent.sol";
import { EquipmentPrototypeComponent, ID as EquipmentPrototypeComponentID } from "./EquipmentPrototypeComponent.sol";
import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";

import { EffectSubSystem, ID as EffectSubSystemID } from "../effect/EffectSubSystem.sol";

uint256 constant ID = uint256(keccak256("system.Equipment"));

enum EquipmentAction {
  UNEQUIP,
  EQUIP
}

/**
 * @title Subsystem to equip stuff to slots based on slot to prototype allowances.
 * @dev Equipment prototypes are a few entities (like `Clothing` or `Boots`) in `EquipmentPrototypeComponent`.
 * Slots are entities defined only by allowed equipment prototypes via `EquipmentSlotAllowedComponent`.
 * (Fun fact: this allows characters to have different/dynamic sets of limbs).
 * Actual equipment entities are anything that uses `FromPrototypeComponent` to link to an equipment prototype.
 * Currently equipped slot=>entity mapping is in `EquipmentSlotComponent`.
 */
contract EquipmentSubSystem is Subsystem {
  error EquipmentSubSystem__InvalidEquipmentAction();
  error EquipmentSubSystem__InvalidEquipmentPrototype();
  error EquipmentSubSystem__SlotNotAllowedForPrototype();
  error EquipmentSubSystem__EquipmentEntityAlreadyEquipped();

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
      // TODO equipmentSlot should be bound to targetEntity, atm they seem too loosely related
      uint256 targetEntity
    ) = abi.decode(arguments, (EquipmentAction, uint256, uint256, uint256));

    EquipmentSlotComponent slotComp = EquipmentSlotComponent(getAddressById(components, EquipmentSlotComponentID));
    EffectSubSystem effectSubSystem = EffectSubSystem(getAddressById(world.systems(), EffectSubSystemID));

    if (equipmentAction == EquipmentAction.UNEQUIP) {
      _unequip(slotComp, effectSubSystem, targetEntity, equipmentSlot);
    } else if (equipmentAction == EquipmentAction.EQUIP) {
      _equip(slotComp, effectSubSystem, targetEntity, equipmentSlot, equipmentEntity);
    } else {
      revert EquipmentSubSystem__InvalidEquipmentAction();
    }

    return "";
  }

  function _unequip(
    EquipmentSlotComponent slotComp,
    EffectSubSystem effectSubSystem,
    uint256 targetEntity,
    uint256 equipmentSlot
  ) internal {
    uint256 equipmentEntity = slotComp.getValue(equipmentSlot);
    slotComp.remove(equipmentSlot);

    effectSubSystem.executeRemove(targetEntity, equipmentEntity);
  }

  function _equip(
    EquipmentSlotComponent slotComp,
    EffectSubSystem effectSubSystem,
    uint256 targetEntity,
    uint256 equipmentSlot,
    uint256 equipmentEntity
  ) internal {
    // unequip first if slot is occupied (otherwise effects will leak)
    if (slotComp.has(equipmentSlot)) {
      _unequip(slotComp, effectSubSystem, targetEntity, equipmentSlot);
    }

    // equipmentEntity must have equipment prototype
    // TODO this looks dubious, and also very long
    FromPrototypeComponent fromProtoComp = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));
    EquipmentPrototypeComponent protoComp = EquipmentPrototypeComponent(
      getAddressById(components, EquipmentPrototypeComponentID)
    );
    uint256 protoEntity = fromProtoComp.getValue(equipmentEntity);
    if (!protoComp.has(protoEntity)) {
      revert EquipmentSubSystem__InvalidEquipmentPrototype();
    }

    // the slot must allow the equipment prototype
    EquipmentSlotAllowedComponent slotAllowedComp = EquipmentSlotAllowedComponent(
      getAddressById(components, EquipmentSlotAllowedComponentID)
    );
    bool isAllowed = slotAllowedComp.hasItem(equipmentSlot, protoEntity);
    if (!isAllowed) {
      revert EquipmentSubSystem__SlotNotAllowedForPrototype();
    }

    // entity may not be equipped in 2 slots
    uint256[] memory slotsWithEquipmentEntity = slotComp.getEntitiesWithValue(equipmentEntity);
    if (slotsWithEquipmentEntity.length > 0) {
      revert EquipmentSubSystem__EquipmentEntityAlreadyEquipped();
    }

    slotComp.set(equipmentSlot, equipmentEntity);

    // reverts if equipmentEntity isn't a valid effectProtoEntity
    // TODO that's good atm because equipment only does effects. But it could do more.
    effectSubSystem.executeApply(targetEntity, equipmentEntity);
  }
}
