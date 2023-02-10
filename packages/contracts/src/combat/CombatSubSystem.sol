// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";
import { Subsystem } from "@dk1a/solecslib/contracts/mud/Subsystem.sol";

import { ActiveCombatComponent, ID as ActiveCombatComponentID } from "./ActiveCombatComponent.sol";
import { ScopedDuration, SystemCallback, DurationSubSystem, ID as DurationSubSystemID } from "../duration/DurationSubSystem.sol";

import { LibActiveCombat } from "./LibActiveCombat.sol";
import { LibCharstat, EL_L } from "../charstat/LibCharstat.sol";
import { LibCombatAction, Action, ActionType, ActorOpts } from "./LibCombatAction.sol";

/// @dev combatDurationEntity = hashed(salt, initiator)
function getCombatDurationEntity(uint256 initiatorEntity) pure returns (uint256) {
  return uint256(keccak256(abi.encode(keccak256("getCombatDurationEntity"), initiatorEntity)));
}

uint256 constant ID = uint256(keccak256("system.Combat"));

/**
 * @title Subsystem to execute 1 combat round between 2 actors; extensively uses charstats.
 * @dev A combat may have multiple rounds, each executed separately.
 * `Action[]` in args allows multiple actions in 1 round. (For another round call execute again).
 * `CombatSubsystem` has multi-actor multi-action interactions logic,
 * and uses `LibCombatAction` for reusable one-way action logic.
 */
contract CombatSubSystem is Subsystem {
  using LibCharstat for LibCharstat.Self;
  using LibCombatAction for LibCombatAction.Self;

  error CombatSubSystem__InvalidExecuteSelector();
  error CombatSubSystem__InvalidActionsLength();
  error CombatSubSystem__ResidualDuration();

  struct CombatActor {
    uint256 entity;
    Action[] actions;
    ActorOpts opts;
  }

  // Result for initiator; it's based on who loses all life first.
  // This just indicates how the combat concluded.
  enum CombatResult {
    NONE,
    VICTORY,
    DEFEAT
  }

  constructor(IWorld _world, address _components) Subsystem(_world, _components) {}

  /**
   * @notice Execute a combat round with default PVE options
   * @dev Player must be the initiator
   */
  function executePVERound(
    uint256 initiatorEntity,
    uint256 retaliatorEntity,
    Action[] memory initiatorActions,
    Action[] memory retaliatorActions
  ) public returns (CombatResult) {
    CombatActor memory initiator = CombatActor({
      entity: initiatorEntity,
      actions: initiatorActions,
      opts: ActorOpts({ maxResistance: 80 })
    });
    CombatActor memory retaliator = CombatActor({
      entity: retaliatorEntity,
      actions: retaliatorActions,
      opts: ActorOpts({ maxResistance: 99 })
    });

    return executeCombatRound(initiator, retaliator);
  }

  /**
   * @notice Execute a combat round with generic actors
   */
  function executeCombatRound(
    CombatActor memory initiator,
    CombatActor memory retaliator
  ) public onlyWriter returns (CombatResult result) {
    // TODO (maybe this check doesn't need to be here?)
    // combat should be externally activated
    LibActiveCombat.requireActiveCombat(components, initiator.entity, retaliator.entity);

    result = _bothActorsActions(initiator, retaliator);

    if (result != CombatResult.NONE) {
      // combat ended - deactivate it
      executeDeactivateCombat(initiator.entity);
    } else {
      // combat keeps going - decrement round durations
      DurationSubSystem durationSubSystem = _durationSubSystem();
      durationSubSystem.executeDecreaseScope(
        initiator.entity,
        ScopedDuration({
          // TODO unhardcode durations in CombatSubSystem
          timeScopeId: uint256(keccak256("round")),
          timeValue: 1
        })
      );
      durationSubSystem.executeDecreaseScope(
        initiator.entity,
        ScopedDuration({ timeScopeId: uint256(keccak256("round_persistent")), timeValue: 1 })
      );
      // if combat duration ran out, initiator loses by default
      uint256 durationEntity = getCombatDurationEntity(initiator.entity);
      if (!durationSubSystem.has(initiator.entity, durationEntity)) {
        executeDeactivateCombat(initiator.entity);
        result = CombatResult.DEFEAT;
      }
    }

    return result;
  }

  /**
   * @notice Combat must be activated first, then `executeCombatRound` can be called until it's over
   */
  function executeActivateCombat(
    uint256 initiatorEntity,
    uint256 retaliatorEntity,
    uint256 maxRounds
  ) public onlyWriter {
    LibActiveCombat.requireNotActiveCombat(components, initiatorEntity);

    ActiveCombatComponent activeCombatComp = ActiveCombatComponent(getAddressById(components, ActiveCombatComponentID));
    activeCombatComp.set(initiatorEntity, retaliatorEntity);

    uint256 durationEntity = getCombatDurationEntity(initiatorEntity);
    DurationSubSystem durationSubSystem = _durationSubSystem();
    if (durationSubSystem.has(initiatorEntity, durationEntity)) {
      // helps catch weird bugs where combat isn't active, but duration still is
      revert CombatSubSystem__ResidualDuration();
    }
    durationSubSystem.executeIncrease(
      initiatorEntity,
      durationEntity,
      ScopedDuration({ timeScopeId: uint256(keccak256("round")), timeValue: maxRounds }),
      SystemCallback(0, "")
    );
  }

  /**
   * @notice Mostly for internal use, but it can also be called to prematurely deactivate combat
   */
  function executeDeactivateCombat(uint256 initiatorEntity) public onlyWriter {
    ActiveCombatComponent activeCombatComp = ActiveCombatComponent(getAddressById(components, ActiveCombatComponentID));
    activeCombatComp.remove(initiatorEntity);

    DurationSubSystem durationSubSystem = _durationSubSystem();
    durationSubSystem.executeDecreaseScope(
      initiatorEntity,
      ScopedDuration({ timeScopeId: uint256(keccak256("round")), timeValue: type(uint256).max })
    );
    durationSubSystem.executeDecreaseScope(
      initiatorEntity,
      ScopedDuration({ timeScopeId: uint256(keccak256("turn")), timeValue: 1 })
    );
  }

  /*//////////////////////////////////////////////////////////////
                              INTERNAL
  //////////////////////////////////////////////////////////////*/

  function _execute(bytes memory args) internal override returns (bytes memory) {
    (bytes4 executeSelector, bytes memory innerArgs) = abi.decode(args, (bytes4, bytes));

    if (executeSelector == this.executeCombatRound.selector) {
      (CombatActor memory initiator, CombatActor memory retaliator) = abi.decode(innerArgs, (CombatActor, CombatActor));
      return abi.encode(executeCombatRound(initiator, retaliator));
    } else if (executeSelector == this.executeActivateCombat.selector) {
      (uint256 initiatorEntity, uint256 retaliatorEntity, uint256 maxRounds) = abi.decode(
        innerArgs,
        (uint256, uint256, uint256)
      );
      executeActivateCombat(initiatorEntity, retaliatorEntity, maxRounds);
      return "";
    } else if (executeSelector == this.executeDeactivateCombat.selector) {
      uint256 initiatorEntity = abi.decode(innerArgs, (uint256));
      executeDeactivateCombat(initiatorEntity);
      return "";
    } else {
      revert CombatSubSystem__InvalidExecuteSelector();
    }
  }

  function _bothActorsActions(
    CombatActor memory initiator,
    CombatActor memory retaliator
  ) internal returns (CombatResult) {
    // TODO use some initiative method instead of initiator always being 1st?
    LibCharstat.Self memory initiatorCharstat = LibCharstat.__construct(components, initiator.entity);
    LibCharstat.Self memory retaliatorCharstat = LibCharstat.__construct(components, retaliator.entity);

    // instant loss if initiator somehow started with 0 life
    if (initiatorCharstat.getLifeCurrent() == 0) return CombatResult.DEFEAT;

    // initiator's actions
    _oneActorActions(initiator, initiatorCharstat, retaliator, retaliatorCharstat);

    // win if retaliator is dead; this interrupts retaliator's actions
    if (retaliatorCharstat.getLifeCurrent() == 0) return CombatResult.VICTORY;

    // retaliator's actions
    _oneActorActions(retaliator, retaliatorCharstat, initiator, initiatorCharstat);

    // loss if initiator is dead
    if (initiatorCharstat.getLifeCurrent() == 0) return CombatResult.DEFEAT;
    // win if retaliator somehow died in its own round
    if (retaliatorCharstat.getLifeCurrent() == 0) return CombatResult.VICTORY;
    // none otherwise
    return CombatResult.NONE;
  }

  function _oneActorActions(
    CombatActor memory attacker,
    LibCharstat.Self memory attackerCharstat,
    CombatActor memory defender,
    LibCharstat.Self memory defenderCharstat
  ) internal {
    _checkActionsLength(attacker);

    LibCombatAction.Self memory combatAction = LibCombatAction.__construct(
      world,
      attackerCharstat,
      attacker.opts,
      defenderCharstat,
      defender.opts
    );

    for (uint256 i; i < attacker.actions.length; i++) {
      combatAction.executeAction(attacker.actions[i]);
    }
  }

  function _checkActionsLength(CombatActor memory actor) internal pure {
    if (actor.actions.length > 1) {
      // TODO a way to do 2 actions in a round, like a special Skill
      // (limited by actionType, 2 attacks in a round is too OP)
      revert CombatSubSystem__InvalidActionsLength();
    }
  }

  function _durationSubSystem() internal view returns (DurationSubSystem) {
    return DurationSubSystem(getAddressById(world.systems(), DurationSubSystemID));
  }
}
