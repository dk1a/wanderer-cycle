// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

enum PStat {
  STRENGTH,
  ARCANA,
  DEXTERITY
}
uint256 constant PS_L = 3;

library LibExperience {
  uint8 constant LEVEL_TOTAL_DIV = 8;

  /**
   * @dev Calculate aggregate level based on weighted sum of pstat exp
   */
  function getAggregateLevel(
    uint32[PS_L] memory experience,
    uint8[PS_L] memory levelMul
  ) internal pure returns (uint8) {
    uint256 expTotal;
    for (uint256 i; i < PS_L; i++) {
        expTotal += experience[i] * levelMul[i];
    }
    
    expTotal /= LEVEL_TOTAL_DIV;

    return getLevel(expTotal);
  }

  /**
   * @dev Calculate level based on single exp value
   */
  function getLevel(uint256 expVal) internal pure returns (uint8) {
    uint8 maxLevel = 32;
    // expVal per level rises exponentially with polynomial easing
    // 1-0, 2-96, 3-312, 4-544, 5-804, 6-1121...
    for (uint8 i = 1; i <= maxLevel; i++) {
      // (1<<i) == 2**i ; can't overflow due to maxLevel
      if (expVal < 8 * (1<<i) - i**6 / 1024 + i * 200 - 120) {
        return i;
      }
    }
    return maxLevel;
  }
}