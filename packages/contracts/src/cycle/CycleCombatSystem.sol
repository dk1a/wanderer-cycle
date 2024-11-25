// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { ActionType } from "../codegen/common.sol";
import { CombatAction, CombatResult } from "../CustomTypes.sol";
import { CombatActionType } from "../codegen/common.sol";
import { CombatSystem } from "../combat/CombatSystem.sol";

import { LibActiveCombat } from "../combat/LibActiveCombat.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibCycleCombatRewardRequest } from "./LibCycleCombatRewardRequest.sol";

contract CycleCombatSystem is System {
  CombatSystem combatSystem;

  function processCombatRound(bytes memory args) public returns (bytes memory) {
    (bytes32 wandererEntity, CombatAction[] memory initiatorActions) = abi.decode(args, (bytes32, CombatAction[]));
    // reverts if sender doesn't have permission
    bytes32 cycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);
    // reverts if combat isn't active
    bytes32 retaliatorEntity = LibActiveCombat.getRetaliatorEntity(cycleEntity);

    // TODO other retaliator actions?
    CombatAction[] memory retaliatorActions = new CombatAction[](1);
    retaliatorActions[0] = CombatAction({ actionType: CombatActionType.ATTACK, actionEntity: 0 });

    CombatResult result = combatSystem.executePVERound(
      cycleEntity,
      retaliatorEntity,
      initiatorActions,
      retaliatorActions
    );

    if (result == CombatResult.VICTORY) {
      LibCycleCombatRewardRequest.requestReward(cycleEntity, retaliatorEntity);
    }

    return abi.encode(result);
  }
}
