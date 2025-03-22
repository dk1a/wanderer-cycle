// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { CycleTurns, CycleTurnsLastClaimed, ActiveGuise } from "../codegen/index.sol";

library LibCycleTurns {
  error LibCycleTurns_NotEnoughTurns();

  // TODO minutes is for testing, change to days
  uint256 constant ACC_PERIOD = 1 minutes;
  uint32 constant TURNS_PER_PERIOD = 10;
  uint32 constant MAX_ACC_PERIODS = 2;
  uint32 constant MAX_CURRENT_TURNS_FOR_CLAIM = 50;

  /**
   * @dev Get the number of currently available cycle turns.
   */
  function getTurns(bytes32 cycleEntity) internal view returns (uint32) {
    return CycleTurns.get(cycleEntity);
  }

  /**
   * @dev Decrease entity's available turns by `subTurns`.
   */
  function decreaseTurns(bytes32 cycleEntity, uint32 subTurns) internal {
    uint32 currentTurns = CycleTurns.get(cycleEntity);
    if (subTurns > currentTurns) revert LibCycleTurns_NotEnoughTurns();
    CycleTurns.set(cycleEntity, currentTurns - subTurns);
  }

  /**
   * @dev Claims all claimable turns.
   */
  function claimTurns(bytes32 cycleEntity) internal {
    uint32 claimableTurns = getClaimableTurns(cycleEntity);
    if (claimableTurns == 0) return;

    CycleTurns.set(cycleEntity, CycleTurns.get(cycleEntity) + claimableTurns);
    CycleTurnsLastClaimed.set(cycleEntity, uint48(block.timestamp));
  }

  /**
   * @dev Get accumulated turns that can be claimed (both accumulation and claim have a cap).
   */
  function getClaimableTurns(bytes32 cycleEntity) internal view returns (uint32) {
    // Get accumulated turns
    uint32 accumulatedTurns = TURNS_PER_PERIOD * _getAccPeriods(cycleEntity);
    assert(accumulatedTurns <= TURNS_PER_PERIOD * MAX_ACC_PERIODS);
    assert(TURNS_PER_PERIOD * MAX_ACC_PERIODS < type(uint256).max);
    // Make sure current turns aren't overcapped (gotta spend some before claiming more)
    uint256 currentTurns = CycleTurns.get(cycleEntity);
    if (currentTurns > MAX_CURRENT_TURNS_FOR_CLAIM) {
      return 0;
    } else {
      return accumulatedTurns;
    }
  }

  /**
   * @dev Can accumulate ACC_PERIODs up to MAX_ACC_PERIODS, claimTurns resets accumulation.
   * The accumulation moment is equal for everyone.
   */
  function _getAccPeriods(bytes32 cycleEntity) private view returns (uint32) {
    uint256 lastClaimedTimestamp = CycleTurnsLastClaimed.get(cycleEntity);
    if (lastClaimedTimestamp == 0) {
      // Timestamp can be 0 for the first claim
      return 1;
    }
    // lastClaimed timestamp in floored periods
    uint256 periodsLast = lastClaimedTimestamp / ACC_PERIOD;
    // Current timestamp in floored periods
    uint256 periodsCurrent = block.timestamp / ACC_PERIOD;
    // Number of periods since the last claim
    uint256 accPeriods = periodsCurrent - periodsLast;
    if (accPeriods > MAX_ACC_PERIODS) {
      return MAX_ACC_PERIODS;
    } else {
      // Typecast is safe because MAX_ACC_PERIODS is uint32
      return uint32(accPeriods);
    }
  }
}
