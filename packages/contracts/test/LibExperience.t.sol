// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { LibExperience } from "../src/charstat/LibExperience.sol";
import { Experience, ExperienceTableId } from "../src/codegen/Tables.sol";
import { PStat_length } from "../src/CustomTypes.sol";

contract LibExperienceTest is MudV2Test {
  bytes32 internal targetEntity = keccak256("targetEntity");

  function setUp() public virtual override {
    super.setUp();
    // TODO remove this if it's integrated into MUD
    vm.startPrank(worldAddress);
  }

  function testHasExp() public {
    assertFalse(LibExperience.hasExp(targetEntity));

    LibExperience.initExp(targetEntity);
    assertTrue(LibExperience.hasExp(targetEntity));
  }

  function _testIncreaseExp(uint32[PStat_length] memory initialExp, uint32[PStat_length] memory addExp)
    internal
    returns (uint32[PStat_length] memory resultExp)
  {
    LibExperience.increaseExp(targetEntity, addExp);

    resultExp = LibExperience.getExp(targetEntity);
    for (uint256 i; i < resultExp.length; i++) {
      assertEq(resultExp[i], initialExp[i] + addExp[i]);
    }
  }

  function testIncreaseExp() public {
    LibExperience.initExp(targetEntity);
    uint32[PStat_length] memory initialExp = LibExperience.getExp(targetEntity);
    initialExp = _testIncreaseExp(initialExp, [uint32(1), 1, 1]);
    initialExp = _testIncreaseExp(initialExp, [uint32(8), 8, 8]);
    initialExp = _testIncreaseExp(initialExp, [uint32(0), 0, 1]);
  }

  function testFuzzIncreaseExp(uint32[PStat_length] memory addExp) public {
    LibExperience.initExp(targetEntity);
    uint32[PStat_length] memory initialExp = LibExperience.getExp(targetEntity);
    initialExp = _testIncreaseExp(initialExp, addExp);
  }

  function testGetExp() public {
    uint32[PStat_length] memory exp = [uint32(10), 20, 30];
    Experience.set(targetEntity, exp);

    uint32[PStat_length] memory retrievedExp = LibExperience.getExp(targetEntity);
    for (uint256 i; i < retrievedExp.length; i++) {
      assertEq(retrievedExp[i], exp[i]);
    }
  }

  function testMaxLevel() public {
    LibExperience.initExp(targetEntity);

    // Set the experience to the maximum level
    uint32[PStat_length] memory maxExp = [type(uint32).max, type(uint32).max, type(uint32).max];
    Experience.set(targetEntity, maxExp);

    assertEq(LibExperience.getAggregateLevel(targetEntity, maxExp), 16);
  }

  function testFuzzPStats(uint32[PStat_length] memory pstats) public {
    for (uint32 i = 0; i < pstats.length; i++) {
      vm.assume(pstats[i] > 0 && pstats[i] <= LibExperience.MAX_LEVEL);
    }

    LibExperience.initExp(targetEntity);
    // Get expected exp for the random pstat values
    uint32[PStat_length] memory expectedExp = LibExperience.getExpForPStats(pstats);
    LibExperience.increaseExp(targetEntity, expectedExp);

    // Get the actual exp
    uint32[PStat_length] memory actualExp = LibExperience.getExp(targetEntity);

    // Ensure that the actual exp matches the expected exp
    for (uint256 i = 0; i < expectedExp.length; i++) {
      assertEq(actualExp[i], expectedExp[i]);
    }
  }
}
