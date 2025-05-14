// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Experience } from "../src/namespaces/charstat/codegen/index.sol";
import { charstatSystem } from "../src/namespaces/charstat/codegen/systems/CharstatSystemLib.sol";
import { LibExperience } from "../src/namespaces/charstat/LibExperience.sol";
import { PStat_length } from "../src/CustomTypes.sol";
import { BaseTest } from "./BaseTest.t.sol";

contract LibExperienceTest is BaseTest {
  bytes32 internal targetEntity = keccak256("targetEntity");

  function testHasExp() public {
    assertFalse(LibExperience.hasExp(targetEntity));

    charstatSystem.initExp(targetEntity);
    assertTrue(LibExperience.hasExp(targetEntity));
  }

  function _testIncreaseExp(
    uint32[PStat_length] memory initialExp,
    uint32[PStat_length] memory addExp
  ) internal returns (uint32[PStat_length] memory resultExp) {
    charstatSystem.increaseExp(targetEntity, addExp);

    resultExp = LibExperience.getExp(targetEntity);
    for (uint256 i; i < resultExp.length; i++) {
      assertEq(resultExp[i], initialExp[i] + addExp[i]);
    }
  }

  function testIncreaseExp() public {
    charstatSystem.initExp(targetEntity);
    uint32[PStat_length] memory initialExp = LibExperience.getExp(targetEntity);
    initialExp = _testIncreaseExp(initialExp, [uint32(1), 1, 1]);
    initialExp = _testIncreaseExp(initialExp, [uint32(8), 8, 8]);
    initialExp = _testIncreaseExp(initialExp, [uint32(0), 0, 1]);
  }

  function testFuzzIncreaseExp(uint32[PStat_length] memory addExp) public {
    charstatSystem.initExp(targetEntity);
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
    charstatSystem.initExp(targetEntity);

    // Set the experience to the maximum level
    uint32[PStat_length] memory maxExp = [type(uint32).max, type(uint32).max, type(uint32).max];
    Experience.set(targetEntity, maxExp);

    assertEq(LibExperience.getAggregateLevel(targetEntity, maxExp), 16);
  }

  function testFuzzPStats(uint8[PStat_length] memory rawPstats) public {
    uint32[PStat_length] memory pstats;
    for (uint32 i = 0; i < rawPstats.length; i++) {
      if (rawPstats[i] > LibExperience.MAX_LEVEL) {
        pstats[i] = (rawPstats[i] % LibExperience.MAX_LEVEL) + 1;
      } else if (rawPstats[i] == 0) {
        pstats[i] = 1;
      } else {
        pstats[i] = rawPstats[i];
      }
    }

    charstatSystem.initExp(targetEntity);
    // Get expected exp for the random pstat values
    uint32[PStat_length] memory expectedExp = LibExperience.getExpForPStats(pstats);
    charstatSystem.increaseExp(targetEntity, expectedExp);

    // Get the actual exp
    uint32[PStat_length] memory actualExp = LibExperience.getExp(targetEntity);

    // Ensure that the actual exp matches the expected exp
    for (uint256 i = 0; i < expectedExp.length; i++) {
      assertEq(actualExp[i], expectedExp[i]);
    }
  }
}
