// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";
import { CycleBossesDefeatedComponent, ID as CycleBossesDefeatedComponentID } from "./CycleBossesDefeatedComponent.sol";
import { Action, ActionType, CombatSubSystem, ID as CombatSubSystemID } from "../combat/CombatSubSystem.sol";
import { EffectSubSystem, ID as EffectSubSystemID } from "../effect/EffectSubSystem.sol";

import { MapPrototypes } from "../map/MapPrototypes.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibActiveCombat } from "../combat/LibActiveCombat.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";

uint256 constant ID = uint256(keccak256("system.CycleActivateCombat"));

contract CycleActivateCombatSystem is System {
  using LibCharstat for LibCharstat.Self;

  error CycleActivateCombatSystem__InvalidMapPrototype();
  error CycleActivateCombatSystem__BossMapAlreadyCleared();

  uint32 constant TURNS_COST = 1;
  uint256 constant MAX_ROUNDS = 12;

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(uint256 wandererEntity, uint256 mapEntity) public {
    execute(abi.encode(wandererEntity, mapEntity));
  }

  function execute(bytes memory args) public override returns (bytes memory) {
    (uint256 wandererEntity, uint256 mapEntity) = abi.decode(args, (uint256, uint256));

    FromPrototypeComponent fromProtoComp = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));
    CycleBossesDefeatedComponent cycleBossesDefeated = CycleBossesDefeatedComponent(
      getAddressById(components, CycleBossesDefeatedComponentID)
    );
    EffectSubSystem effectSubSystem = EffectSubSystem(getAddressById(world.systems(), EffectSubSystemID));
    CombatSubSystem combatSubSystem = CombatSubSystem(getAddressById(world.systems(), CombatSubSystemID));

    // reverts if sender doesn't have permission
    uint256 cycleEntity = LibCycle.getCycleEntityPermissioned(components, wandererEntity);
    // reverts if combat is active
    LibActiveCombat.requireNotActiveCombat(components, cycleEntity);
    // reverts if map isn't GLOBAL_ (they are ownerless and can be used by anyone)
    uint256 mapProtoEntity = fromProtoComp.getValue(mapEntity);
    if (
      mapProtoEntity != MapPrototypes.GLOBAL_BASIC &&
      mapProtoEntity != MapPrototypes.GLOBAL_RANDOM &&
      mapProtoEntity != MapPrototypes.GLOBAL_CYCLE_BOSS
    ) {
      revert CycleActivateCombatSystem__InvalidMapPrototype();
    }
    // TODO level checks
    // reverts if boss is already defeated
    if (mapProtoEntity == MapPrototypes.GLOBAL_CYCLE_BOSS) {
      if (cycleBossesDefeated.hasItem(cycleEntity, mapEntity)) {
        revert CycleActivateCombatSystem__BossMapAlreadyCleared();
      }
    }
    // reverts if not enough turns
    LibCycleTurns.decreaseTurns(components, cycleEntity, TURNS_COST);

    // spawn new entity for map
    uint256 retaliatorEntity = world.getUniqueEntityId();
    // apply map effects (this affects values of charstats, so must happen 1st)
    effectSubSystem.executeApply(retaliatorEntity, mapEntity);
    // init currents
    LibCharstat.Self memory charstat = LibCharstat.__construct(components, retaliatorEntity);
    charstat.setFullCurrents();
    // TODO I think this should have its own component
    // set map (not mapProto) as retaliator's prototype so it can be referenced later for rewards and stuff
    fromProtoComp.set(retaliatorEntity, mapEntity);

    // activate combat
    combatSubSystem.executeActivateCombat(cycleEntity, retaliatorEntity, MAX_ROUNDS);

    return "";
  }
}
