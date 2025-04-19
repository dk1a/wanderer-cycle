// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { hasKey } from "@latticexyz/world-modules/src/modules/keysintable/hasKey.sol";
import { Experience } from "./codegen/tables/Experience.sol";
import { PStat, PStat_length } from "../../CustomTypes.sol";

library LibExperience {
  error LibExperience_InvalidLevel(uint32 level);

  uint32 internal constant MAX_LEVEL = 16;

  function getPStats(bytes32 targetEntity) internal view returns (uint32[PStat_length] memory result) {
    result = Experience.get(targetEntity);
    for (uint256 i; i < result.length; i++) {
      result[i] = _getLevel(result[i]);
    }
  }

  function getPStat(bytes32 targetEntity, PStat pstatIndex) internal view returns (uint32) {
    uint32 exp = Experience.get(targetEntity)[uint256(pstatIndex)];
    return _getLevel(exp);
  }

  function hasExp(bytes32 targetEntity) internal view returns (bool) {
    bytes32[] memory keyTuple = new bytes32[](1);
    keyTuple[0] = targetEntity;
    return hasKey(Experience._tableId, keyTuple);
  }

  function getExp(bytes32 targetEntity) internal view returns (uint32[PStat_length] memory) {
    return Experience.get(targetEntity);
  }

  /**
   * @dev Calculate aggregate level based on weighted sum of pstat exp
   */
  function getAggregateLevel(
    bytes32 targetEntity,
    uint32[PStat_length] memory levelMul
  ) internal view returns (uint32) {
    uint32[PStat_length] memory exp = getExp(targetEntity);
    uint256 expTotal;
    uint256 mulTotal;
    for (uint256 i; i < PStat_length; i++) {
      expTotal += uint256(exp[i]) * levelMul[i];
      mulTotal += levelMul[i];
    }

    if (mulTotal != 0) {
      expTotal /= mulTotal;
    }

    return _getLevel(expTotal);
  }

  /**
   * @dev Calculate level based on single exp value
   */
  function _getLevel(uint256 expVal) internal pure returns (uint32) {
    // expVal per level rises exponentially with polynomial easing
    // 1-0, 2-96, 3-312, 4-544, 5-804, 6-1121...
    for (uint32 level = 1; level < MAX_LEVEL; level++) {
      // (1<<i) == 2**i ; can't overflow due to maxLevel
      if (expVal < _getExpForLevel(level + 1)) {
        return level;
      }
    }
    return MAX_LEVEL;
  }

  /**
   * @dev Utility function to reverse a level into its required exp
   */
  function _getExpForLevel(uint32 level) private pure returns (uint32) {
    if (level < 1 || level > MAX_LEVEL) revert LibExperience_InvalidLevel(level);

    // this formula starts from 0, so adjust the arg
    if (level == 1) {
      return 0;
    } else {
      level -= 1;
    }

    return uint32(8 * (1 << level) - level ** 6 / 1024 + level * 200 - 120);
  }

  /**
   * @dev Get exp amount to get base primary to `pstats` (assuming 0 current exp).
   * This is a utility for testing
   */
  function getExpForPStats(uint32[PStat_length] memory pstats) internal pure returns (uint32[PStat_length] memory exp) {
    for (uint256 i; i < PStat_length; i++) {
      exp[i] = _getExpForLevel(pstats[i]);
    }
  }

  /**
   * @dev same as getExpForPStats but for 1 specific pstat
   */
  function getExpForPStat(uint32 pstat) internal pure returns (uint32) {
    return _getExpForLevel(pstat);
  }
}
