// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { CombatAction } from "../../CustomTypes.sol";
import { CombatActionType, CombatResult } from "../../codegen/common.sol";

import { combatSystem } from "../combat/codegen/systems/CombatSystemLib.sol";

import { LibActiveCombat } from "../combat/LibActiveCombat.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibCycleCombatRewardRequest } from "./LibCycleCombatRewardRequest.sol";

contract CycleCombatSystem is System {
  function processCycleCombatRound(
    bytes32 cycleEntity,
    CombatAction[] memory initiatorActions
  ) public returns (CombatResult result) {
    LibCycle.requireAccess(cycleEntity);

    // Reverts if combat isn't active
    bytes32 retaliatorEntity = LibActiveCombat.getRetaliatorEntity(cycleEntity);

    // TODO other retaliator actions?
    CombatAction[] memory retaliatorActions = new CombatAction[](1);
    retaliatorActions[0] = CombatAction({ actionType: CombatActionType.ATTACK, actionEntity: 0 });

    result = combatSystem.actPVERound(cycleEntity, retaliatorEntity, initiatorActions, retaliatorActions);

    if (result == CombatResult.VICTORY) {
      LibCycleCombatRewardRequest.requestReward(cycleEntity, retaliatorEntity);
    }
  }
}
