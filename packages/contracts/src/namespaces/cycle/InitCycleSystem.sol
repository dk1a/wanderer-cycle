// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { GuisePrototype } from "../root/codegen/tables/GuisePrototype.sol";
import { ActiveCycle } from "./codegen/tables/ActiveCycle.sol";
import { ActiveGuise } from "./codegen/tables/ActiveGuise.sol";
import { CycleOwner } from "./codegen/tables/CycleOwner.sol";
import { CycleMetadata } from "./codegen/tables/CycleMetadata.sol";

import { charstatSystem } from "../charstat/codegen/systems/CharstatSystemLib.sol";
import { learnSkillSystem } from "../skill/codegen/systems/LearnSkillSystemLib.sol";
import { equipmentSystem } from "../equipment/codegen/systems/EquipmentSystemLib.sol";
import { wheelSystem } from "../wheel/codegen/systems/WheelSystemLib.sol";

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
    // cycleEntity is for all the in-cycle components (everything except activeCycle)
    cycleEntity = getUniqueEntity();
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
    // Copy permanent skills
    learnSkillSystem.copySkills(wandererEntity, cycleEntity);

    return cycleEntity;
  }
}
