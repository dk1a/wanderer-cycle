// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { CombatActors } from "../combat/codegen/tables/CombatActors.sol";
import { CombatAction } from "../../CustomTypes.sol";
import { CombatActionType, CombatResult } from "../../codegen/common.sol";

import { combatSystem } from "../combat/codegen/systems/CombatSystemLib.sol";

import { LibActiveCombat } from "./LibActiveCombat.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibCycleCombatRewardRequest } from "./LibCycleCombatRewardRequest.sol";

contract CycleCombatSystem is System {
  function processCycleCombatRound(
    bytes32 cycleEntity,
    CombatAction[] memory initiatorActions
  ) public returns (CombatResult result, bytes32 rewardRequestId) {
    LibCycle.requireAccess(cycleEntity);

    // Reverts if combat isn't active
    bytes32 combatEntity = LibActiveCombat.getCombatEntity(cycleEntity);

    // TODO other retaliator actions?
    CombatAction[] memory retaliatorActions = new CombatAction[](1);
    retaliatorActions[0] = CombatAction({ actionType: CombatActionType.ATTACK, actionEntity: 0 });

    result = combatSystem.actPVERound(combatEntity, initiatorActions, retaliatorActions);

    if (result != CombatResult.NONE) {
      LibActiveCombat.deactivateCombat(cycleEntity);
    }

    if (result == CombatResult.VICTORY) {
      bytes32 retaliatorEntity = CombatActors.getRetaliatorEntity(combatEntity);
      rewardRequestId = LibCycleCombatRewardRequest.requestReward(combatEntity, cycleEntity, retaliatorEntity);
    }
  }
}
