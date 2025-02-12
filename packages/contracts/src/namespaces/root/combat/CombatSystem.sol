// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { CombatResult, CombatAction, CombatActorOpts, CombatActor } from "../../../CustomTypes.sol";
import { GenericDurationData } from "../../duration/Duration.sol";
import { ActiveCombat, ActiveCombatData } from "../codegen/index.sol";
import { CombatActionType } from "../../../codegen/common.sol";

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibTime } from "../LibTime.sol";
import { LibActiveCombat } from "./LibActiveCombat.sol";
import { LibCombatAction } from "./LibCombatAction.sol";

/**
 * @title Subsystem to execute 1 combat round between 2 actors; extensively uses charstats.
 * @dev A combat may have multiple rounds, each executed separately.
 * `CombatAction[]` in args allows multiple actions in 1 round. (For another round call execute again).
 * `CombatSubsystem` has multi-actor multi-action interactions logic,
 * and uses `LibCombatAction` for reusable one-way action logic.
 */
contract CombatSystem is System {
  error CombatSystem_InvalidActionsLength();
  error CombatSystem_ResidualDuration();

  /**
   * @notice Execute a combat round with default PVE options
   * @dev Player must be the initiator
   */
  function executePVERound(
    bytes32 initiatorEntity,
    bytes32 retaliatorEntity,
    CombatAction[] memory initiatorActions,
    CombatAction[] memory retaliatorActions
  ) public returns (CombatResult result) {
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
    result = executeCombatRound(initiator, retaliator);

    return result;
  }

  /**
   * @notice Execute a combat round with generic actors
   */
  function executeCombatRound(
    CombatActor memory initiator,
    CombatActor memory retaliator
  ) public returns (CombatResult result) {
    bool isFinalRound = LibActiveCombat.spendRound(initiator.entity, retaliator.entity);

    result = _bothActorsActions(initiator, retaliator);

    if (result != CombatResult.NONE) {
      // combat ended - deactivate it
      executeDeactivateCombat(initiator.entity);
    } else {
      // combat keeps going - decrement round durations
      LibTime.decreaseApplications(initiator.entity, GenericDurationData({ timeId: keccak256("round"), timeValue: 1 }));
      LibTime.decreaseApplications(
        initiator.entity,
        GenericDurationData({ timeId: keccak256("round_persistent"), timeValue: 1 })
      );
      // if combat duration ran out, initiator loses by default
      if (isFinalRound) {
        executeDeactivateCombat(initiator.entity);
        result = CombatResult.DEFEAT;
      }
    }

    return result;
  }

  /**
   * @notice Combat must be activated first, then `executeCombatRound` can be called until it's over
   */
  function executeActivateCombat(bytes32 initiatorEntity, bytes32 retaliatorEntity, uint32 maxRounds) public {
    LibActiveCombat.requireNotActiveCombat(initiatorEntity);

    ActiveCombat.set(
      initiatorEntity,
      ActiveCombatData({ retaliatorEntity: retaliatorEntity, roundsSpent: 0, roundsMax: maxRounds })
    );
  }

  /**
   * @notice Mostly for internal use, but it can also be called to prematurely deactivate combat
   */
  function executeDeactivateCombat(bytes32 initiatorEntity) public {
    ActiveCombat.deleteRecord(initiatorEntity);

    LibTime.decreaseApplications(
      initiatorEntity,
      GenericDurationData({ timeId: keccak256("round"), timeValue: type(uint256).max })
    );
    LibTime.decreaseApplications(initiatorEntity, GenericDurationData({ timeId: keccak256("turn"), timeValue: 1 }));
  }

  /*//////////////////////////////////////////////////////////////
                              INTERNAL
  //////////////////////////////////////////////////////////////*/

  function _bothActorsActions(
    CombatActor memory initiator,
    CombatActor memory retaliator
  ) internal returns (CombatResult) {
    // instant loss if initiator somehow started with 0 life
    if (LibCharstat.getLifeCurrent(initiator.entity) == 0) return CombatResult.DEFEAT;

    // initiator's actions
    _oneActorActions(initiator, retaliator);

    // win if retaliator is dead; this interrupts retaliator's actions
    if (LibCharstat.getLifeCurrent(retaliator.entity) == 0) return CombatResult.VICTORY;

    // retaliator's actions
    _oneActorActions(retaliator, initiator);

    // loss if initiator is dead
    if (LibCharstat.getLifeCurrent(initiator.entity) == 0) return CombatResult.DEFEAT;
    // win if retaliator somehow died in its own round
    if (LibCharstat.getLifeCurrent(retaliator.entity) == 0) return CombatResult.VICTORY;
    // none otherwise
    return CombatResult.NONE;
  }

  function _oneActorActions(CombatActor memory attacker, CombatActor memory defender) internal {
    _checkActionsLength(attacker);

    for (uint256 i; i < attacker.actions.length; i++) {
      LibCombatAction.executeAction(attacker.entity, defender.entity, attacker.actions[i], defender.opts);
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
