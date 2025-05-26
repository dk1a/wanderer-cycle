// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { GuisePrototype } from "../root/codegen/tables/GuisePrototype.sol";
import { ActiveCycle } from "./codegen/tables/ActiveCycle.sol";
import { ActiveGuise } from "./codegen/tables/ActiveGuise.sol";
import { CycleOwner } from "./codegen/tables/CycleOwner.sol";
import { CycleMetadata } from "./codegen/tables/CycleMetadata.sol";

import { charstatSystem } from "../charstat/codegen/systems/CharstatSystemLib.sol";
import { equipmentSystem } from "../equipment/codegen/systems/EquipmentSystemLib.sol";
import { wheelSystem } from "../wheel/codegen/systems/WheelSystemLib.sol";

import { LibSOFClass } from "../common/LibSOFClass.sol";
import { LibSpawnEquipmentSlots } from "../equipment/LibSpawnEquipmentSlots.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";

/**
 * @title Internal cycle initialization logic
 * @dev The only non-public cycle system
 */
contract InitCycleSystem is System {
  error InitCycleSystem_DuplicateActiveCycle();
  error InitCycleSystem_InvalidGuiseEntity();

  function initCycle(
    bytes32 wandererEntity,
    bytes32 guiseEntity,
    bytes32 wheelEntity
  ) public returns (bytes32 cycleEntity) {
    // cycleEntity is the key for all the in-cycle tables
    // (everything except ActiveCycle, which maps and enforces 1 active cycle per owner)
    cycleEntity = LibSOFClass.instantiate("cycle");

    // Cycle must be inactive
    if (ActiveCycle.get(wandererEntity) != bytes32(0)) {
      revert InitCycleSystem_DuplicateActiveCycle();
    }
    // Prototypes must exist
    uint32[3] memory guiseProto = GuisePrototype.get(guiseEntity);
    if (guiseProto[0] == 0 && guiseProto[1] == 0 && guiseProto[2] == 0) {
      revert InitCycleSystem_InvalidGuiseEntity();
    }

    wheelSystem.activateWheel(wandererEntity, cycleEntity, wheelEntity);

    // Set active cycle and its owner
    ActiveCycle.set(wandererEntity, cycleEntity);
    CycleOwner.set(cycleEntity, wandererEntity);
    // Set cycle metadata
    CycleMetadata.setStartTime(cycleEntity, block.timestamp);
    // Set active guise
    ActiveGuise.set(cycleEntity, guiseEntity);
    // Init exp and currents
    charstatSystem.initExp(cycleEntity);
    charstatSystem.setFullCurrents(cycleEntity);
    // Claim initial cycle turns
    LibCycleTurns.claimTurns(cycleEntity);
    // Spawn equipment slots
    equipmentSystem.spawnEquipmentSlots(cycleEntity);

    return cycleEntity;
  }
}
