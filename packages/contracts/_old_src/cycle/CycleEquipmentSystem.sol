// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { EquipmentSubSystem, ID as EquipmentSubSystemID, EquipmentAction } from "../equipment/EquipmentSubSystem.sol";
import { OwnedByComponent, ID as OwnedByComponentID } from "../common/OwnedByComponent.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibLootOwner } from "../loot/LibLootOwner.sol";

uint256 constant ID = uint256(keccak256("system.CycleEquipment"));

contract CycleEquipmentSystem is System {
  error CycleEquipmentSystem__NotSlotOwner();
  error CycleEquipmentSystem__NotEquipmentOwner();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(
    EquipmentAction equipmentAction,
    uint256 wandererEntity,
    uint256 equipmentSlot,
    uint256 equipmentEntity
  ) public {
    execute(abi.encode(equipmentAction, wandererEntity, equipmentSlot, equipmentEntity));
  }

  function execute(bytes memory args) public override returns (bytes memory) {
    (EquipmentAction equipmentAction, uint256 wandererEntity, uint256 equipmentSlot, uint256 equipmentEntity) = abi
      .decode(args, (EquipmentAction, uint256, uint256, uint256));

    // reverts if sender doesn't have permission
    uint256 cycleEntity = LibCycle.getCycleEntityPermissioned(components, wandererEntity);

    // the caller must own the equipment slot
    OwnedByComponent ownedByComponent = OwnedByComponent(getAddressById(components, OwnedByComponentID));
    if (cycleEntity != ownedByComponent.getValue(equipmentSlot)) {
      revert CycleEquipmentSystem__NotSlotOwner();
    }
    // and the equipment
    // TODO allow the entity which has `equipmentEntity` equipped to unequip it without owning it
    if (cycleEntity != LibLootOwner.ownerOf(components, equipmentEntity)) {
      revert CycleEquipmentSystem__NotEquipmentOwner();
    }

    EquipmentSubSystem equipmentSubsystem = EquipmentSubSystem(getAddressById(world.systems(), EquipmentSubSystemID));
    equipmentSubsystem.executeTyped(equipmentAction, equipmentSlot, equipmentEntity);

    return "";
  }
}
