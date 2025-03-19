// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";

import { SystemSwitch } from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { ActiveGuise, ActiveWheel, PreviousCycle, Wheel, WheelData, GuisePrototype, ActiveCycle } from "../codegen/index.sol";

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibExperience } from "../charstat/LibExperience.sol";
import { LibSpawnEquipmentSlots } from "../equipment/LibSpawnEquipmentSlots.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibLearnedSkills } from "../skill/LibLearnedSkills.sol";
import { ERC721Namespaces } from "../token/ERC721Namespaces.sol";

library LibCycle {
  error LibCycle_CycleIsAlreadyActive();
  error LibCycle_CycleNotActive();
  error LibCycle_InvalidGuiseEntity();
  error LibCycle_InvalidWheelEntity();

  function initCycle(
    bytes32 wandererEntity,
    bytes32 guiseEntity,
    bytes32 wheelEntity
  ) internal returns (bytes32 cycleEntity) {
    // cycleEntity is for all the in-cycle components (everything except activeCycle)
    cycleEntity = getUniqueEntity();
    // Cycle must be inactive
    if (ActiveCycle.get(wandererEntity) != bytes32(0)) {
      revert LibCycle_CycleIsAlreadyActive();
    }
    // Prototypes must exist
    uint32[3] memory guiseProto = GuisePrototype.get(guiseEntity);
    if (guiseProto[0] == 0 && guiseProto[1] == 0 && guiseProto[2] == 0) {
      revert LibCycle_InvalidGuiseEntity();
    }
    WheelData memory wheel = Wheel.get(wheelEntity);
    if (wheel.totalIdentityRequired == 0 && wheel.charges == 0 && !wheel.isIsolated) {
      // TODO enable when wheel init is added
      //revert LibCycle_InvalidWheelEntity();
    }

    LibCycleInternalPart2.initCyclePart2(wandererEntity, cycleEntity, guiseEntity, wheelEntity);

    return cycleEntity;
  }

  function endCycle(bytes32 wandererEntity, bytes32 cycleEntity) internal {
    // Save the previous cycle entity
    PreviousCycle.set(wandererEntity, cycleEntity);
    // Clear the current cycle
    ActiveCycle.deleteRecord(wandererEntity);
  }

  /**
   * @dev Return `cycleEntity` if _msgSender() is allowed to use it.
   * Revert otherwise.
   *
   * Note on why getCycleEntity and a permission check are 1 method:
   * Cycle systems take `wandererEntity` as the argument to simplify checking permissions,
   * and then convert it to `cycleEntity`. If you don't need permission checks,
   * you probably shouldn't need this method either, and should know cycle entities directly.
   */
  function getCycleEntityPermissioned(bytes32 wandererEntity) internal view returns (bytes32 cycleEntity) {
    // Check permission
    ERC721Namespaces.WandererNFT.requireOwner(WorldContextConsumerLib._msgSender(), wandererEntity);
    // Get cycle entity
    if (ActiveCycle.get(wandererEntity) == 0) revert LibCycle_CycleNotActive();
    return ActiveCycle.get(wandererEntity);
  }
}

// This is separate and public only to split codesize
library LibCycleInternalPart2 {
  function initCyclePart2(
    bytes32 wandererEntity,
    bytes32 cycleEntity,
    bytes32 guiseEntity,
    bytes32 wheelEntity
  ) public {
    // Set active cycle
    ActiveCycle.set(wandererEntity, cycleEntity);
    // Set active guise
    ActiveGuise.set(cycleEntity, guiseEntity);
    // Set active wheel
    ActiveWheel.set(cycleEntity, wheelEntity);
    // Init exp
    LibExperience.initExp(cycleEntity);
    // Init currents
    LibCharstat.setFullCurrents(cycleEntity);
    // Claim initial cycle turns
    LibCycleTurns.claimTurns(cycleEntity);
    // Spawn equipment slots
    LibSpawnEquipmentSlots.spawnEquipmentSlots(cycleEntity);
    // Copy permanent skills
    LibLearnedSkills.copySkills(wandererEntity, guiseEntity);
  }
}
