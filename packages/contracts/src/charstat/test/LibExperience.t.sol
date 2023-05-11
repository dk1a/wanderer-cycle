// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../LibExperience.sol";
import "../ExperienceComponent.sol";

contract LibExperienceTest {
  using LibExperience for LibExperience.Self;

  LibExperience.Self private libExperience;
  ExperienceComponent private experienceComponent;
  uint256 private targetEntity;

  function beforeEach() public {
    experienceComponent = new ExperienceComponent();
    targetEntity = 1;
    libExperience = LibExperience.__construct(IUint256Component(address(experienceComponent)), targetEntity);
  }

  function testIncreaseExp() public {
    // Initialize exp
    libExperience.initExp();
    assert(libExperience.hasExp());
    uint32[PS_L] memory addExp = [1, 1, 1, 1, 1, 1, 1, 1];
    libExperience.increaseExp(addExp);
    uint32[PS_L] memory exp = libExperience.getExp();
    assert(
      exp[0] == 1 &&
        exp[1] == 1 &&
        exp[2] == 1 &&
        exp[3] == 1 &&
        exp[4] == 1 &&
        exp[5] == 1 &&
        exp[6] == 1 &&
        exp[7] == 1
    );
  }

  function testGetAggregateLevel() public {
    // Initialize exp
    libExperience.initExp();
    assert(libExperience.hasExp());

    // Increase exp for each pstat
    for (uint256 i = 0; i < PS_L; i++) {
      uint32[PS_L] memory addExp = [0, 0, 0, 0, 0, 0, 0, 0];
      addExp[i] = LibExperience._getExpForLevel(2);
      libExperience.increaseExp(addExp);
    }

    // Calculate aggregate level
    uint32[PS_L] memory levelMul = [1, 1, 1, 1, 1, 1, 1, 1];
    uint32 aggregateLevel = libExperience.getAggregateLevel(levelMul);
    assert(aggregateLevel == 2);
  }
}
