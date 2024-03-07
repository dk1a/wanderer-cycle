// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { SystemSwitch } from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { ActiveGuise, ActiveWheel, PreviousCycle, Wheel, WheelData, GuisePrototype, ActiveCycle, CycleToWanderer } from "../codegen/index.sol";
import { ICycleInitSystem } from "../codegen/world/ICycleInitSystem.sol";

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibExperience } from "../charstat/LibExperience.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibLearnedSkills } from "../skill/LibLearnedSkills.sol";

//import { LibToken } from "../token/LibToken.sol";
//import { LibSpawnEquipmentSlots } from "../equipment/LibSpawnEquipmentSlots.sol";

library LibCycle {
  error LibCycle_CycleIsAlreadyActive();
  error LibCycle_CycleNotActive();
  error LibCycle_InvalidGuiseProtoEntity();
  error LibCycle_InvalidWheelEntity();

  function initCycle(
    bytes32 wandererEntity,
    bytes32 guiseProtoEntity,
    bytes32 wheelEntity
  ) internal returns (bytes32 cycleEntity) {
    // cycleEntity is for all the in-cycle components (everything except activeCycle)
    cycleEntity = getUniqueEntity();
    // cycle must be inactive
    if (ActiveCycle.get(wandererEntity) != bytes32(0)) {
      revert LibCycle_CycleIsAlreadyActive();
    }
    // prototypes must exist
    uint32[3] memory guiseProto = GuisePrototype.get(guiseProtoEntity);
    if (guiseProto[0] == 0 && guiseProto[1] == 0 && guiseProto[2] == 0) {
      revert LibCycle_InvalidGuiseProtoEntity();
    }
    WheelData memory wheel = Wheel.get(wheelEntity);
    if (wheel.totalIdentityRequired == 0 && wheel.charges == 0 && !wheel.isIsolated) {
      // TODO enable when wheel init is added
      //revert LibCycle_InvalidWheelEntity();
    }

    SystemSwitch.call(
      abi.encodeCall(ICycleInitSystem.initCycle, (wandererEntity, cycleEntity, guiseProtoEntity, wheelEntity))
    );

    return cycleEntity;
  }

  function endCycle(bytes32 wandererEntity, bytes32 cycleEntity) internal {
    // save the previous cycle entity
    PreviousCycle.set(wandererEntity, cycleEntity);
    // clear the current cycle
    ActiveCycle.deleteRecord(wandererEntity);
    CycleToWanderer.deleteRecord(cycleEntity);
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
    if (ActiveCycle.get(wandererEntity) == 0) revert LibCycle_CycleNotActive();
    return ActiveCycle.get(wandererEntity);
  }

  function requirePermission(bytes32 cycleEntity) internal view {
    // get wanderer entity
    bytes32 wandererEntity = CycleToWanderer.get(cycleEntity);
    // check permission
    // LibToken.requireOwner(wandererEntity, msg.sender);
  }
}
