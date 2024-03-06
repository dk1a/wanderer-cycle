// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { ActiveGuise, ActiveWheel, PreviousCycle, Wheel, WheelData, GuisePrototype, ActiveCycle, CycleToWanderer } from "../codegen/index.sol";

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibExperience } from "../charstat/LibExperience.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibLearnedSkills } from "../skill/LibLearnedSkills.sol";

/// @title Spawn a wandererEntity and start a cycle for it.
/// @dev This is for new players, whereas StartCycle is for existing ones.
contract CycleInitSystem is System {
  error CycleInitSystem__CycleIsAlreadyActive();
  error CycleInitSystem__InvalidGuiseProtoEntity();
  error CycleInitSystem__InvalidWheelEntity();

  function initCycle(
    bytes32 targetEntity,
    bytes32 guiseProtoEntity,
    bytes32 wheelEntity
  ) public returns (bytes32 cycleEntity) {
    // cycleEntity is for all the in-cycle components (everything except activeCycle)
    cycleEntity = getUniqueEntity();
    // cycle must be inactive
    if (ActiveCycle.get(targetEntity) != bytes32(0)) {
      revert CycleInitSystem__CycleIsAlreadyActive();
    }
    // prototypes must exist
    uint32[3] memory guiseProto = GuisePrototype.get(guiseProtoEntity);
    if (guiseProto[0] == 0 && guiseProto[1] == 0 && guiseProto[2] == 0) {
      revert CycleInitSystem__InvalidGuiseProtoEntity();
    }
    WheelData memory wheel = Wheel.get(wheelEntity);
    if (wheel.totalIdentityRequired == 0 && wheel.charges == 0 && !wheel.isIsolated) {
      revert CycleInitSystem__InvalidWheelEntity();
    }

    // set active cycle and its reverse mapping
    ActiveCycle.set(targetEntity, cycleEntity);
    CycleToWanderer.set(cycleEntity, targetEntity);
    // set active guise
    ActiveGuise.set(cycleEntity, guiseProtoEntity);
    // set active wheel
    ActiveWheel.set(cycleEntity, wheelEntity);
    // init exp
    LibExperience.initExp(targetEntity);
    // init currents
    LibCharstat.setFullCurrents(targetEntity);
    // claim initial cycle turns
    LibCycleTurns.claimTurns(cycleEntity);
    // spawn equipment slots
    //    LibSpawnEquipmentSlots.spawnEquipmentSlots(cycleEntity);
    // copy permanent skills
    LibLearnedSkills.copySkills(targetEntity, guiseProtoEntity);

    return cycleEntity;
  }
}
