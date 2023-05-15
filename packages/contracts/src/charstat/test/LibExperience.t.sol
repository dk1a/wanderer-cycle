// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibExperience } from "../LibExperience.sol";
import { PStat, PS_L } from "../ExperienceComponent.sol";
import { BaseTest } from "../../BaseTest.sol";

contract LibExperienceTest is BaseTest {
  using LibExperience for uint256;

  uint256 targetEntity = uint256(keccak256("targetEntity"));

  function testGetPStats() public {
    uint32[PS_L] memory pstats = [100, 200, 300];
    uint32[PS_L] memory expectedExp = LibExperience.getExpForPStats(pstats);

    experienceComponent.set(targetEntity, expectedExp);

    uint32[PS_L] memory resultPStats = LibExperience.getPStats(targetEntity);
    for (uint256 i; i < pstats.length; i++) {
      assertEq32(resultPStats[i], pstats[i]);
    }
  }

  function testGetPStat() public {
    uint32 pstatStrength = 10;
    uint32 expStrength = LibExperience.getExpForPStat(pstatStrength);

    experienceComponent.update(targetEntity, uint256(PStat.STRENGTH), expStrength);

    uint32 resultPStat = LibExperience.getPStat(targetEntity, PStat.STRENGTH);
    assertEq32(resultPStat, pstatStrength);
  }

  function testHasExp() public {
    bool result = targetEntity.hasExp();
    assert(!result);

    experienceComponent.set(targetEntity, [100, 200, 300]);

    result = targetEntity.hasExp();
    assert(result);
  }

  function testInitExp() public {
    targetEntity.initExp();

    bool result = targetEntity.hasExp();
    assert(result);

    uint32[PS_L] memory resultExp = targetEntity.getExp();
    for (uint256 i; i < resultExp.length; i++) {
      assertEq32(resultExp[i], 0);
    }
  }

  function testIncreaseExp() public {
    uint32[PS_L] memory addExp = [10, 20, 30];
    uint32[PS_L] memory expectedExp = [110, 220, 330];

    experienceComponent.set(targetEntity, [100, 200, 300]);

    targetEntity.increaseExp(addExp);

    uint32[PS_L] memory resultExp = targetEntity.getExp();
    for (uint256 i; i < resultExp.length; i++) {
      assertEq32(resultExp[i], expectedExp[i]);
    }
  }

  function testGetAggregateLevel() public {
    uint32[PS_L] memory exp = [100, 200, 300];
    uint32[PS_L] memory levelMul = [1, 2, 3];
    // Expected aggregate level: ((100*1) + (200*2) + (300*3)) / (1+2+3) = 200

    experienceComponent.set(targetEntity, exp);

    uint32 resultLevel = targetEntity.getAggregateLevel(levelMul);
    assertEq32(resultLevel, 200);
  }
}
