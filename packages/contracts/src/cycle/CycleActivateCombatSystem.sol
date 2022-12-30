// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";
import {
  Action,
  ActionType,
  CombatSubsystem,
  ID as CombatSubsystemID
} from "../combat/CombatSubsystem.sol";
import { EffectSubsystem, ID as EffectSubsystemID } from "../effect/EffectSubsystem.sol";

import { MapPrototypes } from "../map/MapPrototypes.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibActiveCombat } from "../combat/LibActiveCombat.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";

uint256 constant ID = uint256(keccak256("system.CycleActivateCombat"));

contract CycleActivateCombatSystem is System {
  using LibCharstat for LibCharstat.Self;

  error CycleActivateCombatSystem__InvalidMapPrototype();

  uint256 constant TURNS_COST = 1;
  uint256 constant MAX_ROUNDS = 12;

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(
    uint256 wandererEntity,
    uint256 mapEntity
  ) public {
    execute(abi.encode(wandererEntity, mapEntity));
  }

  function execute(bytes memory args) public override returns (bytes memory) {
    (
      uint256 wandererEntity,
      uint256 mapEntity
    ) = abi.decode(args, (uint256, uint256));

    FromPrototypeComponent fromProtoComp
      = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));
    EffectSubsystem effectSubsystem
      = EffectSubsystem(getAddressById(world.systems(), EffectSubsystemID));
    CombatSubsystem combatSubsystem
      = CombatSubsystem(getAddressById(world.systems(), CombatSubsystemID));

    // reverts if sender doesn't have permission
    uint256 cycleEntity = LibCycle.getCycleEntityPermissioned(components, wandererEntity);
    // reverts if combat is active
    LibActiveCombat.requireNotActiveCombat(components, cycleEntity);
    // reverts if map isn't GLOBAL_BASIC (they are ownerless and can be used by anyone)
    if (fromProtoComp.getValue(mapEntity) != MapPrototypes.GLOBAL_BASIC) {
      revert CycleActivateCombatSystem__InvalidMapPrototype();
    }
    // reverts if not enough turns
    LibCycleTurns.decreaseTurns(components, cycleEntity, TURNS_COST);

    // spawn new entity for map
    uint256 retaliatorEntity = world.getUniqueEntityId();
    // apply map effects (this affects values of charstats, so must happen 1st)
    effectSubsystem.executeApply(retaliatorEntity, mapEntity);
    // init currents
    LibCharstat.Self memory charstat = LibCharstat.__construct(components, retaliatorEntity);
    charstat.setFullCurrents();
    // TODO I think this should have its own component
    // set map (not mapProto) as retaliator's prototype so it can be referenced later for rewards and stuff
    fromProtoComp.set(retaliatorEntity, mapEntity);

    // activate combat
    combatSubsystem.executeActivateCombat(
      cycleEntity,
      retaliatorEntity,
      MAX_ROUNDS
    );

    return '';
  }
}