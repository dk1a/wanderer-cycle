// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

// TODO SystemFacet is a crutch
import { SystemFacet } from "@dk1a/solecslib/contracts/mud/SystemFacet.sol";
import { SystemStorage } from "@dk1a/solecslib/contracts/mud/SystemStorage.sol";

import { LibCharstat, EL_L } from "../charstat/LibCharstat.sol";
import { LibCombatAction, Action, ActionType, ActorOpts } from "./LibCombatAction.sol";

uint256 constant ID = uint256(keccak256("system.Combat"));

/**
 * @title Library-like system for other systems that need combat
 */
contract CombatSystem is SystemFacet {
  using LibCharstat for LibCharstat.Self;
  using LibCombatAction for LibCombatAction.Self;

  error CombatSystem__InvalidActionsLength();

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

  constructor(IWorld _world, address _components) {
    __SystemFacet_init(_world, _components);
  }

  /**
   * @notice Execute a combat round with default PVE options
   * @dev Player must be the initiator
   */
  function executePVE(
    uint256 initiatorEntity,
    uint256 retaliatorEntity,
    Action[] memory initiatorActions,
    Action[] memory retaliatorActions
  ) public returns (CombatResult) {
    CombatActor memory initiator = CombatActor({
      entity: initiatorEntity,
      actions: initiatorActions,
      opts: ActorOpts({
        maxResistance: 80
      })
    });
    CombatActor memory retaliator = CombatActor({
      entity: retaliatorEntity,
      actions: retaliatorActions,
      opts: ActorOpts({
        maxResistance: 99
      })
    });

    return executeTyped(initiator, retaliator);
  }

  /**
   * @notice Execute a combat round with generic actors
   */
  function executeTyped(
    CombatActor memory initiator,
    CombatActor memory retaliator
  ) public returns (CombatResult) {
    return abi.decode(
      execute(abi.encode(initiator, retaliator)),
      (CombatResult)
    );
  }

  /**
   * @notice Execute a combat round with generic actors
   * @dev Call `authorizeWriter` for executors
   */
  function execute(bytes memory arguments) public onlyWriter returns (bytes memory) {
    (
      CombatActor memory initiator,
      CombatActor memory retaliator
    ) = abi.decode(arguments, (CombatActor, CombatActor));

    // TODO use some initiative method instead of initiator always being 1st?

    LibCharstat.Self memory initiatorCharstat = LibCharstat.__construct(
      SystemStorage.layout().components,
      initiator.entity
    );

    LibCharstat.Self memory retaliatorCharstat = LibCharstat.__construct(
      SystemStorage.layout().components,
      retaliator.entity
    );

    // instant loss if initiator somehow started with 0 life
    if (initiatorCharstat.getLifeCurrent() == 0) return abi.encode(CombatResult.DEFEAT);
    
    // initiator's actions
    _executeCombatActions(initiator, initiatorCharstat, retaliator, retaliatorCharstat);

    // win if retaliator is dead; and retaliator's actions are interrupted
    if (retaliatorCharstat.getLifeCurrent() == 0) return abi.encode(CombatResult.VICTORY);

    // retaliator's actions
    _executeCombatActions(retaliator, retaliatorCharstat, initiator, initiatorCharstat);

    // loss if initiator is dead
    if (initiatorCharstat.getLifeCurrent() == 0) return abi.encode(CombatResult.DEFEAT);
    // win if retaliator somehow died in its own round
    if (retaliatorCharstat.getLifeCurrent() == 0) return abi.encode(CombatResult.VICTORY);
    // none otherwise
    return abi.encode(CombatResult.NONE);
  }

  function _executeCombatActions(
    CombatActor memory attacker,
    LibCharstat.Self memory attackerCharstat,
    CombatActor memory defender,
    LibCharstat.Self memory defenderCharstat
  ) internal {
    _checkActionsLength(attacker);

    LibCombatAction.Self memory combatAction = LibCombatAction.__construct(
      SystemStorage.layout().components,
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
      // TODO a way to do 2 actions in a round, like a special skill
      // (limited by actionType, 2 attacks in a round is too OP)
      revert CombatSystem__InvalidActionsLength();
    }
  }
}