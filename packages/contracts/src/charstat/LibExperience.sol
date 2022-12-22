// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";
import {
  PStat, PS_L,
  ExperienceComponent,
  ID as ExperienceComponentID
} from "./ExperienceComponent.sol";

library LibExperience {
  error LibExperience__InvalidLevel();
  error LibExperience__ExpNotInitialized();

  uint8 constant LEVEL_TOTAL_DIV = 8;
  uint32 constant MAX_LEVEL = 16;

  struct Self {
    ExperienceComponent comp;
    uint256 targetEntity;
  }

  function __construct(
    IUint256Component registry,
    uint256 targetEntity
  ) internal view returns (Self memory) {
    return Self({
      comp: ExperienceComponent(getAddressById(registry, ExperienceComponentID)),
      targetEntity: targetEntity
    });
  }

  function getPStats(
    Self memory __self
  ) internal view returns (uint32[PS_L] memory result) {
    result = __self.comp.getValue(__self.targetEntity);
    for (uint256 i; i < result.length; i++) {
      result[i] = _getLevel(result[i]);
    }
  }

  function getPStat(
    Self memory __self,
    PStat pstatIndex
  ) internal view returns (uint32) {
    uint32 exp = __self.comp.getValue(__self.targetEntity)[uint256(pstatIndex)];
    return _getLevel(exp);
  }

  function hasExp(Self memory __self) internal view returns (bool) {
    return __self.comp.has(__self.targetEntity);
  }

  function getExp(
    Self memory __self
  ) internal view returns (uint32[PS_L] memory) {
    return __self.comp.getValue(__self.targetEntity);
  }

  /**
   * @dev Allow target to receive exp, set exp to 0s
   */
  function initExp(Self memory __self) internal {
    uint32[PS_L] memory exp;
    __self.comp.set(__self.targetEntity, exp);
  }

  /**
   * @dev Increase target's experience
   * Exp must be initialized
   */
  function increaseExp(
    Self memory __self,
    uint32[PS_L] memory addExp
  ) internal {
    // get current exp, or revert if it doesn't exist
    if (!__self.comp.has(__self.targetEntity)) {
      revert LibExperience__ExpNotInitialized();
    }
    uint32[PS_L] memory exp = __self.comp.getValue(__self.targetEntity);

    // increase
    for (uint256 i; i < PS_L; i++) {
      exp[i] += addExp[i];
    }
    // set increased exp
    __self.comp.set(__self.targetEntity, exp);
  }

  /**
   * @dev Calculate aggregate level based on weighted sum of pstat exp
   */
  function getAggregateLevel(
    Self memory __self,
    uint32[PS_L] memory levelMul
  ) private view returns (uint32) {
    uint32[PS_L] memory exp = getExp(__self);
    uint256 expTotal;
    for (uint256 i; i < PS_L; i++) {
        expTotal += exp[i] * levelMul[i];
    }
    
    expTotal /= LEVEL_TOTAL_DIV;

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

    return uint32(
      8 * (1<<level) - level**6 / 1024 + level * 200 - 120
    );
  }

  /**
   * @dev Get exp amount to get base primary to `pstats` (assuming 0 current exp).
   * This is a utility for testing
   */
  function getExpForPStats(
    uint32[PS_L] memory pstats
  ) internal pure returns (uint32[PS_L] memory exp) {
    for (uint256 i; i < PS_L; i++) {
      exp[i] = _getExpForLevel(pstats[i]);
    }
  }

  /**
   * @dev same as getExpForPStats but for 1 specific pstat
   */
  function getExpForPStat(
    uint32 pstat
  ) internal pure returns (uint32) {
    return _getExpForLevel(pstat);
  }
}