// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world-modules/uniqueentity/getUniqueEntity.sol";

import { ActiveGuise, ActiveWheel, PreviousCycle, Wheel, GuisePrototype, ActiveCycle } from "../codegen/Tables.sol";

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibExperience } from "../charstat/LibExperience.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";

//import { LibToken } from "../token/LibToken.sol";
//import { LibSpawnEquipmentSlots } from "../equipment/LibSpawnEquipmentSlots.sol";
import { LibLearnedSkills } from "../skill/LibLearnedSkills.sol";

library LibCycle {
  error LibCycle__CycleIsAlreadyActive();
  error LibCycle__CycleNotActive();
  error LibCycle__InvalidGuiseProtoEntity();
  error LibCycle__InvalidWheelEntity();

  function initCycle(
    bytes32 targetEntity,
    bytes32 guiseProtoEntity,
    bytes32 wheelEntity
  ) internal returns (bytes32 cycleEntity) {
    // cycleEntity is for all the in-cycle components (everything except activeCycle)
    cycleEntity = getUniqueEntity();
    // cycle must be inactive
    if (!ActiveCycle.get(targetEntity) == 0) {
      revert LibCycle__CycleIsAlreadyActive();
    }
    // prototypes must exist
    if (GuisePrototype.get(guiseProtoEntity) == 0) {
      revert LibCycle__InvalidGuiseProtoEntity();
    }
    if (Wheel.get(wheelEntity) == 0) {
      revert LibCycle__InvalidWheelEntity();
    }

    // set active cycle
    ActiveCycle.set(targetEntity, cycleEntity);
    // TODO new table?
    //    cycleToWandererComp.set(cycleEntity, targetEntity);
    // set active guise
    ActiveGuise.set(cycleEntity, guiseProtoEntity);
    // set active wheel
    ActiveWheel.set(cycleEntity, wheelEntity);
    //    // init exp
    //    LibCharstat.initExp();
    //    // init currents
    //    LibCharstat.setFullCurrents();
    // claim initial cycle turns
    LibCycleTurns.claimTurns(cycleEntity);
    // spawn equipment slots
    //    LibSpawnEquipmentSlots.spawnEquipmentSlots(cycleEntity);
    // copy permanent skills
    //    LibLearnedSkills.copySkills(targetEntity);

    return cycleEntity;
  }

  function endCycle(bytes32 wandererEntity, bytes32 cycleEntity) internal {
    // save the previous cycle entity
    ActiveCycle.set(wandererEntity, cycleEntity);
    // clear the current cycle
    ActiveCycle.deleteRecord(wandererEntity);
    // TODO new table?
    //    cycleToWandererComp.deleteRecord(cycleEntity);
  }

  /// @dev Return `cycleEntity` if msg.sender is allowed to use it.
  /// Revert otherwise.
  ///
  /// Note on why getCycleEntity and a permission check are 1 method:
  /// Cycle systems take `wandererEntity` as the argument to simplify checking permissions,
  /// and then convert it to `cycleEntity`. If you don't need permission checks,
  /// you probably shouldn't need this method either, and should know cycle entities directly.
  function getCycleEntityPermissioned(bytes32 wandererEntity) internal view returns (bytes32 cycleEntity) {
    // check permission
    //    LibToken.requireOwner(wandererEntity, msg.sender);
    // get cycle entity
    if (ActiveCycle.get(wandererEntity) == 0) revert LibCycle__CycleNotActive();
    return ActiveCycle.get(wandererEntity);
  }

  //  function requirePermission(bytes32 cycleEntity) internal view {
  //    // get wanderer entity
  //    // TODO new table?
  //    //    bytes32 wandererEntity = cycleToWandererComp.get(cycleEntity);
  //    // check permission
  //    LibToken.requireOwner(wandererEntity, msg.sender);
  //  }
}
