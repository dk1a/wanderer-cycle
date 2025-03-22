// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { CombatAction, CombatResult } from "../../../CustomTypes.sol";
import { CombatActionType } from "../../../codegen/common.sol";

import { combatSystem } from "../codegen/systems/CombatSystemLib.sol";

import { LibActiveCombat } from "../combat/LibActiveCombat.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibCycleCombatRewardRequest } from "./LibCycleCombatRewardRequest.sol";

contract CycleCombatSystem is System {
  function processCycleCombatRound(
    bytes32 wandererEntity,
    CombatAction[] memory initiatorActions
  ) public returns (CombatResult result) {
    // Reverts if sender doesn't have permission
    bytes32 cycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);
    // Reverts if combat isn't active
    bytes32 retaliatorEntity = LibActiveCombat.getRetaliatorEntity(cycleEntity);

    // TODO other retaliator actions?
    CombatAction[] memory retaliatorActions = new CombatAction[](1);
    retaliatorActions[0] = CombatAction({ actionType: CombatActionType.ATTACK, actionEntity: 0 });

    result = combatSystem.callAsRootFrom(address(this)).actPVERound(
      cycleEntity,
      retaliatorEntity,
      initiatorActions,
      retaliatorActions
    );

    if (result == CombatResult.VICTORY) {
      LibCycleCombatRewardRequest.requestReward(cycleEntity, retaliatorEntity);
    }
  }
}
