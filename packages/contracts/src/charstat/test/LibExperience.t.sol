// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { BaseTest } from "../../BaseTest.sol";
import "../LibExperience.sol";
import "../ExperienceComponent.sol";

contract TestLibExperience is BaseTest {
  ExperienceComponent experienceComponent;
  LibExperience.Self libExperience;

  function setUp() public {
    experienceComponent = new ExperienceComponent(address(this));
    libExperience = LibExperience.__construct(IUint256Component(address(experienceComponent)), 1);
  }

  function testInitExp() public {
    assertTrue(!libExperience.hasExp(), "Exp should not be initialized yet");

    libExperience.initExp();

    assertTrue(libExperience.hasExp(), "Exp should be initialized");

    uint32[PS_L] memory expectedExp;
    assertDeepEq(expectedExp, libExperience.getExp(), "Exp should be all zeros after initialization");
  }

  function testIncreaseExp() public {
    assertTrue(!libExperience.hasExp(), "Exp should not be initialized yet");

    libExperience.initExp();
    assertTrue(libExperience.hasExp(), "Exp should be initialized");

    uint32[PS_L] memory expToAdd = [10, 20, 30];
    libExperience.increaseExp(expToAdd);
    uint32[PS_L] memory expectedExp = [10, 20, 30];
    assertDeepEq(expectedExp, libExperience.getExp(), "Exp should be incremented");
  }

  function testGetAggregateLevel() public {
    uint32[PS_L] memory pstats = [1, 2, 3];
    uint32[PS_L] memory levelMul = [1, 2, 3];

    libExperience.initExp();
    libExperience.increaseExp(LibExperience.getExpForPStats(pstats));

    uint32 expectedLevel = 2;
    uint32 actualLevel = libExperience.getAggregateLevel(levelMul);

    assertEq(expectedLevel, actualLevel, "Aggregate level should be calculated correctly");
  }
}
