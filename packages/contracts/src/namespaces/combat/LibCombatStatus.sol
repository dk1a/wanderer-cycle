// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { CombatStatus, CombatStatusData } from "./codegen/tables/CombatStatus.sol";
import { CombatResult } from "../../codegen/common.sol";

library LibCombatStatus {
  error LibCombatStatus_DuplicateInit(bytes32 combatEntity);
  error LibCombatStatus_NotInitialized(bytes32 combatEntity);
  error LibCombatStatus_CombatIsOver(bytes32 combatEntity);
  error LibCombatStatus_RoundsOverMax(bytes32 combatEntity);

  function initialize(bytes32 combatEntity, uint32 roundsMax) internal {
    if (CombatStatus.getIsInitialized(combatEntity)) {
      revert LibCombatStatus_DuplicateInit(combatEntity);
    }
    CombatStatus.set(
      combatEntity,
      CombatStatusData({ isInitialized: true, combatResult: CombatResult.NONE, roundsSpent: 0, roundsMax: roundsMax })
    );
  }

  /**
   * @dev Reverts if the combat has not been initialized, or has ended
   * @return data The combat status data
   */
  function requireActiveCombat(bytes32 combatEntity) internal view returns (CombatStatusData memory data) {
    data = CombatStatus.get(combatEntity);
    // Combat must have been initialized
    if (!data.isInitialized) revert LibCombatStatus_NotInitialized(combatEntity);
    // And not ended yet
    if (data.combatResult != CombatResult.NONE) revert LibCombatStatus_CombatIsOver(combatEntity);
  }

  function setCombatResult(bytes32 combatEntity, CombatResult combatResult) internal {
    requireActiveCombat(combatEntity);
    CombatStatus.setCombatResult(combatEntity, combatResult);
  }

  /**
   * @dev Spend a single combat round, and return info on the updated round
   * @return roundIndex index of the updated combat round
   * @return isFinalRound whether the updated combat round is the final one, based on roundsMax
   */
  function spendRound(bytes32 combatEntity) internal returns (uint256 roundIndex, bool isFinalRound) {
    CombatStatusData memory data = requireActiveCombat(combatEntity);

    uint32 roundsSpent = data.roundsSpent;
    uint32 roundsMax = data.roundsMax;

    if (roundsSpent + 1 > roundsMax) {
      // This should be unreachable due to CombatIsOver check in requireActiveCombat
      revert LibCombatStatus_RoundsOverMax(combatEntity);
    }

    CombatStatus.setRoundsSpent(combatEntity, roundsSpent + 1);

    roundIndex = roundsSpent;
    isFinalRound = roundsSpent + 1 == roundsMax;

    return (roundIndex, isFinalRound);
  }
}
