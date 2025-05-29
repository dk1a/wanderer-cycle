// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { SmartObjectFramework } from "../evefrontier/SmartObjectFramework.sol";

import { CombatAction, CombatActorOpts, CombatActor } from "../../CustomTypes.sol";
import { GenericDurationData } from "../duration/Duration.sol";
import { CombatActors } from "./codegen/tables/CombatActors.sol";
import { CombatLogRoundOffchain } from "./codegen/tables/CombatLogRoundOffchain.sol";
import { CombatLogActionOffchain, CombatLogActionOffchainData } from "./codegen/tables/CombatLogActionOffchain.sol";
import { CombatActionType, CombatResult } from "../../codegen/common.sol";

import { timeSystem } from "../time/codegen/systems/TimeSystemLib.sol";
import { LibSOFClass } from "../common/LibSOFClass.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibCombatStatus } from "./LibCombatStatus.sol";
import { LibCombatSingleAction, CombatActionDamageLog } from "./LibCombatSingleAction.sol";

/**
 * @title Internal system to execute 1 combat round between 2 actors; extensively uses charstats.
 * @dev A combat may have multiple rounds, each executed separately.
 * `CombatAction[]` in args allows multiple actions in 1 round. (For another round call `actCombatRound` again).
 * `CombatSystem` has multi-actor multi-action interactions logic,
 * and uses `LibCombatSingleAction` for reusable one-way action logic.
 */
contract CombatSystem is SmartObjectFramework {
  error CombatSystem_InvalidActionsLength();

  /**
   * @notice Act a combat round with default PVE options
   * @dev Player must be the initiator
   */
  function actPVERound(
    bytes32 combatEntity,
    CombatAction[] memory initiatorActions,
    CombatAction[] memory retaliatorActions
  ) public context returns (CombatResult result) {
    _requireEntityLeaf(combatEntity);

    (bytes32 initiatorEntity, bytes32 retaliatorEntity) = CombatActors.get(combatEntity);

    CombatActor memory initiator = CombatActor({
      entity: initiatorEntity,
      actions: initiatorActions,
      opts: CombatActorOpts({ maxResistance: 80 })
    });
    CombatActor memory retaliator = CombatActor({
      entity: retaliatorEntity,
      actions: retaliatorActions,
      opts: CombatActorOpts({ maxResistance: 99 })
    });
    result = _actCombatRound(combatEntity, initiator, retaliator);

    return result;
  }

  /**
   * @notice Combat must be activated first, then round actions can be executed
   */
  function activateCombat(
    bytes32 initiatorEntity,
    bytes32 retaliatorEntity,
    uint32 roundsMax,
    ResourceId[] memory combatEntityScopedSystemIds
  ) public context returns (bytes32 combatEntity) {
    // Caller must be scoped for both combat participant entities
    _requireEntityBranch(initiatorEntity);
    _requireEntityBranch(retaliatorEntity);

    combatEntity = LibSOFClass.instantiate("combat", combatEntityScopedSystemIds);
    LibCombatStatus.initialize(combatEntity, roundsMax);
    CombatActors.set(combatEntity, initiatorEntity, retaliatorEntity);
  }

  /*//////////////////////////////////////////////////////////////
                              INTERNAL
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Execute a combat round with generic actors
   */
  function _actCombatRound(
    bytes32 combatEntity,
    CombatActor memory initiator,
    CombatActor memory retaliator
  ) internal returns (CombatResult result) {
    // Reverts if combat isn't active
    (uint256 roundIndex, bool isFinalRound) = LibCombatStatus.spendRound(combatEntity);

    result = _bothActorsActions(combatEntity, roundIndex, initiator, retaliator);

    // Offchain log the round
    CombatLogRoundOffchain.setCombatResult(combatEntity, roundIndex, result);

    if (result != CombatResult.NONE) {
      // Combat ended - deactivate it
      _deactivateCombat(combatEntity, initiator.entity, result);
    } else {
      // Combat keeps going - decrement round durations
      timeSystem.passRounds(initiator.entity, 1);
      timeSystem.passRounds(retaliator.entity, 1);
      // If combat duration ran out, initiator loses by default
      if (isFinalRound) {
        result = CombatResult.DEFEAT;
        _deactivateCombat(combatEntity, initiator.entity, result);
      }
    }

    return result;
  }

  function _deactivateCombat(bytes32 combatEntity, bytes32 initiatorEntity, CombatResult combatResult) internal {
    LibCombatStatus.setCombatResult(combatEntity, combatResult);
    // TODO this may be needed for retaliator too?
    timeSystem.passTurns(initiatorEntity, 1);
  }

  function _bothActorsActions(
    bytes32 combatEntity,
    uint256 roundIndex,
    CombatActor memory initiator,
    CombatActor memory retaliator
  ) internal returns (CombatResult) {
    // Instant loss if initiator somehow started with 0 life
    if (LibCharstat.getLifeCurrent(initiator.entity) == 0) return CombatResult.DEFEAT;

    // Initiator's actions
    _oneActorActions(combatEntity, roundIndex, initiator, retaliator);
    CombatLogRoundOffchain.setInitiatorActionLength(combatEntity, roundIndex, initiator.actions.length);

    // Win if retaliator is dead; this interrupts retaliator's actions
    if (LibCharstat.getLifeCurrent(retaliator.entity) == 0) return CombatResult.VICTORY;

    // Retaliator's actions
    _oneActorActions(combatEntity, roundIndex, retaliator, initiator);
    CombatLogRoundOffchain.setRetaliatorActionLength(combatEntity, roundIndex, retaliator.actions.length);

    // Loss if initiator is dead
    if (LibCharstat.getLifeCurrent(initiator.entity) == 0) return CombatResult.DEFEAT;
    // Win if retaliator somehow died in its own round
    if (LibCharstat.getLifeCurrent(retaliator.entity) == 0) return CombatResult.VICTORY;
    // None otherwise
    return CombatResult.NONE;
  }

  function _oneActorActions(
    bytes32 combatEntity,
    uint256 roundIndex,
    CombatActor memory attacker,
    CombatActor memory defender
  ) internal {
    _checkActionsLength(attacker);

    for (uint256 actionIndex; actionIndex < attacker.actions.length; actionIndex++) {
      uint32 defenderLifeBefore = LibCharstat.getLifeCurrent(defender.entity);

      CombatActionDamageLog memory damageLog = LibCombatSingleAction.executeAction(
        attacker.entity,
        defender.entity,
        attacker.actions[actionIndex],
        defender.opts
      );

      uint32 defenderLifeAfter = LibCharstat.getLifeCurrent(defender.entity);
      // Offchain log the action
      CombatLogActionOffchain.set(
        combatEntity,
        attacker.entity,
        defender.entity,
        roundIndex,
        actionIndex,
        CombatLogActionOffchainData({
          actionType: attacker.actions[actionIndex].actionType,
          actionEntity: attacker.actions[actionIndex].actionEntity,
          defenderLifeBefore: defenderLifeBefore,
          defenderLifeAfter: defenderLifeAfter,
          withAttack: damageLog.withAttack,
          withSpell: damageLog.withSpell,
          attackDamage: damageLog.attackDamage,
          spellDamage: damageLog.spellDamage
        })
      );
    }
  }

  function _checkActionsLength(CombatActor memory actor) internal pure {
    if (actor.actions.length > 1) {
      // TODO a way to do 2 actions in a round, like a special skill
      // (limited by actionType, 2 attacks in a round is too OP)
      revert CombatSystem_InvalidActionsLength();
    }
  }
}
