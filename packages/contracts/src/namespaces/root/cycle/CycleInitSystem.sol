// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { ActiveGuise, ActiveWheel, ActiveCycle, CycleToWanderer } from "../codegen/index.sol";

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibExperience } from "../charstat/LibExperience.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibLearnedSkills } from "../skill/LibLearnedSkills.sol";

// TODO this is only needed to split codesize, make it a public lib when those are supported
contract CycleInitSystem is System {
  function initCycle(
    bytes32 wandererEntity,
    bytes32 cycleEntity,
    bytes32 guiseProtoEntity,
    bytes32 wheelEntity
  ) public {
    // set active cycle and its reverse mapping
    ActiveCycle.set(wandererEntity, cycleEntity);
    CycleToWanderer.set(cycleEntity, wandererEntity);
    // set active guise
    ActiveGuise.set(cycleEntity, guiseProtoEntity);
    // set active wheel
    ActiveWheel.set(cycleEntity, wheelEntity);
    // init exp
    LibExperience.initExp(cycleEntity);
    // init currents
    LibCharstat.setFullCurrents(cycleEntity);
    // claim initial cycle turns
    LibCycleTurns.claimTurns(cycleEntity);
    // spawn equipment slots
    //    LibSpawnEquipmentSlots.spawnEquipmentSlots(cycleEntity);
    // copy permanent skills
    LibLearnedSkills.copySkills(wandererEntity, guiseProtoEntity);
  }
}
