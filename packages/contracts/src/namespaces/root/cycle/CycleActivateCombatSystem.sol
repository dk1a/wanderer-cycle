// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { MapTypeComponent } from "../codegen/tables/MapTypeComponent.sol";
import { FromMap } from "../codegen/tables/FromMap.sol";
import { BossesDefeated } from "../codegen/tables/BossesDefeated.sol";

import { combatSystem } from "../codegen/systems/CombatSystemLib.sol";

import { MapTypes, MapType } from "../map/MapType.sol";
import { LibEffect } from "../../effect/LibEffect.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibActiveCombat } from "../combat/LibActiveCombat.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";

contract CycleActivateCombatSystem is System {
  error CycleActivateCombatSystem_InvalidMapType(bytes32 mapEntity, MapType mapType);
  error CycleActivateCombatSystem_BossMapAlreadyCleared();

  uint32 constant TURNS_COST = 1;
  uint32 constant MAX_ROUNDS = 12;

  function activateCycleCombat(bytes32 wandererEntity, bytes32 mapEntity) public returns (bytes32 encounterEntity) {
    // Reverts if sender doesn't have permission
    bytes32 cycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);
    // Reverts if combat is active
    LibActiveCombat.requireNotActiveCombat(cycleEntity);
    // Reverts if map has invalid type
    MapType mapType = MapTypeComponent.get(mapEntity);
    if (mapType != MapTypes.BASIC && mapType != MapTypes.RANDOM && mapType != MapTypes.CYCLE_BOSS) {
      revert CycleActivateCombatSystem_InvalidMapType(mapEntity, mapType);
    }
    // TODO level checks and less weird hardcode
    // Reverts if boss is already defeated
    if (mapType == MapTypes.CYCLE_BOSS) {
      bytes32[] memory bosses = BossesDefeated.get(cycleEntity);
      bool has = false;
      for (uint256 i = 0; i < bosses.length; i++) {
        if (bosses[i] == mapEntity) {
          has = true;
          break;
        }
      }
      if (has) {
        revert CycleActivateCombatSystem_BossMapAlreadyCleared();
      }
    }
    // TODO handle other map types

    // Reverts if not enough turns
    LibCycleTurns.decreaseTurns(cycleEntity, TURNS_COST);

    // Spawn new entity for the map encounter
    encounterEntity = getUniqueEntity();
    // Apply map effects (this affects values of charstats, so must happen 1st)
    LibEffect.applyEffect(encounterEntity, mapEntity);
    // Init currents
    LibCharstat.setFullCurrents(encounterEntity);
    // Set the map entity as encounter's map so it can be referenced later for rewards and stuff
    FromMap.set(encounterEntity, mapEntity);

    // Activate combat
    combatSystem.callAsRootFrom(address(this)).activateCombat(cycleEntity, encounterEntity, MAX_ROUNDS);
  }
}
