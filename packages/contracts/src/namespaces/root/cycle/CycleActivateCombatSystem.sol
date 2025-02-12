// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { BossesDefeated, FromTemplate } from "../codegen/index.sol";

import { ActionType } from "../../../codegen/common.sol";
//import { Action } from "../combat/LibCombatAction.sol";
import { CombatSystem } from "../combat/CombatSystem.sol";

import { LibEffect } from "../../effect/LibEffect.sol";
import { MapTypes, MapType } from "../map/MapType.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibActiveCombat } from "../combat/LibActiveCombat.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";

contract CycleActivateCombatSystem is System {
  error CycleActivateCombatSystem__InvalidMapPrototype();
  error CycleActivateCombatSystem__BossMapAlreadyCleared();

  CombatSystem combatSystem;

  uint32 constant TURNS_COST = 1;
  uint32 constant MAX_ROUNDS = 12;

  function execute(bytes memory args) public returns (bytes memory) {
    (bytes32 wandererEntity, bytes32 mapEntity) = abi.decode(args, (bytes32, bytes32));

    // reverts if sender doesn't have permission
    bytes32 cycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);
    // reverts if combat is active
    LibActiveCombat.requireNotActiveCombat(cycleEntity);
    // reverts if map isn't GLOBAL_ (they are ownerless and can be used by anyone)
    bytes32 mapProtoEntity = FromTemplate.get(mapEntity);
    if (
      mapProtoEntity != MapType.unwrap(MapTypes.BASIC) &&
      mapProtoEntity != MapType.unwrap(MapTypes.RANDOM) &&
      mapProtoEntity != MapType.unwrap(MapTypes.CYCLE_BOSS)
    ) {
      revert CycleActivateCombatSystem__InvalidMapPrototype();
    }
    // TODO level checks
    // reverts if boss is already defeated
    if (mapProtoEntity == MapType.unwrap(MapTypes.CYCLE_BOSS)) {
      bytes32[] memory bosses = BossesDefeated.get(cycleEntity);
      bool has = false;
      for (uint i = 0; i < bosses.length; i++) {
        if (bosses[i] == mapEntity) {
          has = true;
          break;
        }
      }
      if (has) {
        revert CycleActivateCombatSystem__BossMapAlreadyCleared();
      }
    }

    // reverts if not enough turns
    LibCycleTurns.decreaseTurns(cycleEntity, TURNS_COST);

    // spawn new entity for map
    bytes32 retaliatorEntity = getUniqueEntity();
    // apply map effects (this affects values of charstats, so must happen 1st)
    LibEffect.applyEffect(retaliatorEntity, mapEntity);
    // init currents
    LibCharstat.setFullCurrents(retaliatorEntity);
    // TODO I think this should have its own component
    // set map (not mapProto) as retaliator's prototype so it can be referenced later for rewards and stuff
    FromTemplate.set(retaliatorEntity, mapEntity);

    // activate combat
    combatSystem.executeActivateCombat(cycleEntity, retaliatorEntity, MAX_ROUNDS);

    return "";
  }
}
