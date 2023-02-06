// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { CycleTurnsComponent, ID as CycleTurnsComponentID } from "./CycleTurnsComponent.sol";
import { CycleTurnsLastClaimedComponent, ID as CycleTurnsLastClaimedComponentID } from "./CycleTurnsLastClaimedComponent.sol";

library LibCycleTurns {
  error LibCycleTurns__NotEnoughTurns();

  uint256 constant ACC_PERIOD = 1 days;
  uint32 constant TURNS_PER_PERIOD = 10;
  uint32 constant MAX_ACC_PERIODS = 2;
  uint32 constant MAX_CURRENT_TURNS_FOR_CLAIM = 50;

  /// @dev Get the number of currently available cycle turns.
  function getTurns(IUint256Component components, uint256 cycleEntity) internal view returns (uint256) {
    return _turnsComp(components).getValue(cycleEntity);
  }

  /// @dev Decrease entity's available turns by `subTurns`.
  function decreaseTurns(IUint256Component components, uint256 cycleEntity, uint32 subTurns) internal {
    CycleTurnsComponent turnsComp = _turnsComp(components);
    uint32 currentTurns = turnsComp.getValue(cycleEntity);
    if (subTurns > currentTurns) revert LibCycleTurns__NotEnoughTurns();
    turnsComp.set(cycleEntity, currentTurns - subTurns);
  }

  /// @dev Claims all claimable turns.
  function claimTurns(IUint256Component components, uint256 cycleEntity) internal {
    uint32 claimableTurns = getClaimableTurns(components, cycleEntity);
    if (claimableTurns == 0) return;

    CycleTurnsComponent turnsComp = _turnsComp(components);
    turnsComp.set(cycleEntity, turnsComp.getValue(cycleEntity) + claimableTurns);
    _lastClaimedComp(components).set(cycleEntity, block.timestamp);
  }

  /// @dev Get accumulated turns that can be claimed (both accumulation and claim have a cap).
  function getClaimableTurns(IUint256Component components, uint256 cycleEntity) internal view returns (uint32) {
    // get accumulated turns
    uint32 accumulatedTurns = TURNS_PER_PERIOD * _getAccPeriods(components, cycleEntity);
    assert(accumulatedTurns <= TURNS_PER_PERIOD * MAX_ACC_PERIODS);
    assert(TURNS_PER_PERIOD * MAX_ACC_PERIODS < type(uint256).max);
    // make sure current turns aren't overcapped (gotta spend some before claiming more)
    uint256 currentTurns = _turnsComp(components).getValue(cycleEntity);
    if (currentTurns > MAX_CURRENT_TURNS_FOR_CLAIM) {
      return 0;
    } else {
      return accumulatedTurns;
    }
  }

  /// @dev Can accumulate ACC_PERIODs up to MAX_ACC_PERIODS, claimTurns resets accumulation.
  /// The accumulation moment is equal for everyone.
  function _getAccPeriods(IUint256Component components, uint256 cycleEntity) private view returns (uint32) {
    uint256 lastClaimedTimestamp = _lastClaimedComp(components).getValue(cycleEntity);
    if (lastClaimedTimestamp == 0) {
      // timestamp can be 0 for the first claim
      return 1;
    }
    // lastClaimed timestamp in floored periods
    uint256 periodsLast = lastClaimedTimestamp / ACC_PERIOD;
    // current timestamp in floored periods
    uint256 periodsCurrent = block.timestamp / ACC_PERIOD;
    // number of periods since the last claim
    uint256 accPeriods = periodsCurrent - periodsLast;
    if (accPeriods > MAX_ACC_PERIODS) {
      return MAX_ACC_PERIODS;
    } else {
      // typecast is safe because MAX_ACC_PERIODS is uint32
      return uint32(accPeriods);
    }
  }

  function _turnsComp(IUint256Component components) private view returns (CycleTurnsComponent) {
    return CycleTurnsComponent(getAddressById(components, CycleTurnsComponentID));
  }

  function _lastClaimedComp(IUint256Component components) private view returns (CycleTurnsLastClaimedComponent) {
    return CycleTurnsLastClaimedComponent(getAddressById(components, CycleTurnsLastClaimedComponentID));
  }
}
