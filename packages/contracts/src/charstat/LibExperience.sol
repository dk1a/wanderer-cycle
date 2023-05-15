// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { PStat, PS_L, ExperienceComponent, ID as ExperienceComponentID } from "./ExperienceComponent.sol";

// const entityKey = {
//   primaryKeys: {
//     entity: EntityId,
//   },
// } as const

//  Experience: {
//       ...entityKey,
//       schema: arrayPStat
//     },

// const arrayPStat = `uint32[${enumPStat.length}]` as const

import { Experience } from "../codegen/Tables.sol";

library LibExperience {
  error LibExperience__InvalidLevel();
  error LibExperience__ExpNotInitialized();

  uint32 constant MAX_LEVEL = 16;

  function getPStats(uint256 targetEntity) internal view returns (uint32[PS_L] memory result) {
    result = Experience.get(targetEntity);
    for (uint256 i; i < result.length; i++) {
      result[i] = _getLevel(result[i]);
    }
  }

  function getPStat(uint256 targetEntity, PStat pstatIndex) internal view returns (uint32) {
    uint32 exp = Experience.get(targetEntity)[uint256(pstatIndex)];
    return _getLevel(exp);
  }

  function hasExp(uint256 targetEntity) internal view returns (bool) {
    uint32 exp = Experience.get(targetEntity);
    if (exp) {
      return true;
    } else {
      return false;
    }
  }

  function getExp(uint256 targetEntity) internal view returns (uint32[PS_L] memory) {
    return Experience.get(targetEntity);
  }

  /**
   * @dev Allow target to receive exp, set exp to 0s
   */
  function initExp(uint256 targetEntity) internal {
    uint32[PS_L] memory exp;
    Experience.set(targetEntity, exp);
  }

  /**
   * @dev Increase target's experience
   * Exp must be initialized
   */
  function increaseExp(uint256 targetEntity, uint32[PS_L] memory addExp) internal {
    // get current exp, or revert if it doesn't exist
    if (!Experience.get(targetEntity)) {
      revert LibExperience__ExpNotInitialized();
    }
    uint32[PS_L] memory exp = Experience.get(targetEntity);

    // increase
    for (uint256 i; i < PS_L; i++) {
      exp[i] += addExp[i];
    }
    // set increased exp
    Experience.set(targetEntity, exp);
  }

  /**
   * @dev Calculate aggregate level based on weighted sum of pstat exp
   */
  function getAggregateLevel(uint256 targetEntity, uint32[PS_L] memory levelMul) internal view returns (uint32) {
    uint32[PS_L] memory exp = getExp(targetEntity);
    uint256 expTotal;
    uint256 mulTotal;
    for (uint256 i; i < PS_L; i++) {
      expTotal += exp[i] * levelMul[i];
      mulTotal += levelMul[i];
    }

    expTotal /= mulTotal;

    return _getLevel(expTotal);
  }

  /**
   * @dev Calculate level based on single exp value
   */
  function _getLevel(uint256 expVal) private pure returns (uint32) {
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
    if (level < 1 || level > MAX_LEVEL) revert LibExperience__InvalidLevel();

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
  function getExpForPStats(uint32[PS_L] memory pstats) internal pure returns (uint32[PS_L] memory exp) {
    for (uint256 i; i < PS_L; i++) {
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
