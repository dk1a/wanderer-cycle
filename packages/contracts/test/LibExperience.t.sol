// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { LibExperience } from "../src/charstat/LibExperience.sol";
import { PStat_length } from "../src/CustomTypes.sol";

contract LibExperienceTest is MudV2Test {
  bytes32 internal targetEntity = keccak256("targetEntity");

  function testIncreaseExp() public {
    // Initialize exp
    LibExperience.initExp(targetEntity);
    assertTrue(LibExperience.hasExp(targetEntity));

    uint32[PStat_length] memory addExp = [uint32(1), 1, 1];
    LibExperience.increaseExp(targetEntity, addExp);

    uint32[PStat_length] memory exp = LibExperience.getExp(targetEntity);
    for (uint256 i; i < exp.length; i++) {
      assertEq(exp[i], 1);
    }
  }
}