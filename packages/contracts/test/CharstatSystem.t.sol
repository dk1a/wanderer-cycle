// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";
import { BaseTest } from "./BaseTest.t.sol";

import { Experience } from "../src/namespaces/charstat/codegen/index.sol";
import { LibSOFClass } from "../src/namespaces/common/LibSOFClass.sol";
import { LibCharstat } from "../src/namespaces/charstat/LibCharstat.sol";
import { LibExperience } from "../src/namespaces/charstat/LibExperience.sol";
import { PStat_length } from "../src/CustomTypes.sol";

contract CharstatSystemTest is BaseTest {
  bytes32 internal targetEntity;

  function setUp() public virtual override {
    super.setUp();

    vm.startPrank(deployer);

    targetEntity = LibSOFClass.instantiate("test", deployer);

    vm.stopPrank();
  }

  function testRevertUnscoped() public {
    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, targetEntity, emptySystemId)
    );
    emptySystemMock.charstat__initExp(targetEntity);

    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, targetEntity, emptySystemId)
    );
    emptySystemMock.charstat__increaseExp(targetEntity, [uint32(100000), 100000, 100000]);

    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, targetEntity, emptySystemId)
    );
    emptySystemMock.charstat__setManaCurrent(targetEntity, 100);

    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, targetEntity, emptySystemId)
    );
    emptySystemMock.charstat__setLifeCurrent(targetEntity, 100);
  }

  function testHasExp() public {
    assertFalse(LibExperience.hasExp(targetEntity));

    scopedSystemMock.charstat__initExp(targetEntity);
    assertTrue(LibExperience.hasExp(targetEntity));
  }

  function _testIncreaseExp(
    uint32[PStat_length] memory initialExp,
    uint32[PStat_length] memory addExp
  ) internal returns (uint32[PStat_length] memory resultExp) {
    scopedSystemMock.charstat__increaseExp(targetEntity, addExp);

    resultExp = LibExperience.getExp(targetEntity);
    for (uint256 i; i < resultExp.length; i++) {
      assertEq(resultExp[i], initialExp[i] + addExp[i]);
    }
  }

  function testIncreaseExp() public {
    scopedSystemMock.charstat__initExp(targetEntity);
    uint32[PStat_length] memory initialExp = LibExperience.getExp(targetEntity);
    initialExp = _testIncreaseExp(initialExp, [uint32(1), 1, 1]);
    initialExp = _testIncreaseExp(initialExp, [uint32(8), 8, 8]);
    initialExp = _testIncreaseExp(initialExp, [uint32(0), 0, 1]);
  }

  function testFuzzIncreaseExp(uint32[PStat_length] memory addExp) public {
    scopedSystemMock.charstat__initExp(targetEntity);
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
    scopedSystemMock.charstat__initExp(targetEntity);

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

    scopedSystemMock.charstat__initExp(targetEntity);
    // Get expected exp for the random pstat values
    uint32[PStat_length] memory expectedExp = LibExperience.getExpForPStats(pstats);
    scopedSystemMock.charstat__increaseExp(targetEntity, expectedExp);

    // Get the actual exp
    uint32[PStat_length] memory actualExp = LibExperience.getExp(targetEntity);

    // Ensure that the actual exp matches the expected exp
    for (uint256 i = 0; i < expectedExp.length; i++) {
      assertEq(actualExp[i], expectedExp[i]);
    }
  }

  function testCurrentCaps() public {
    scopedSystemMock.charstat__initExp(targetEntity);
    assertEq(LibCharstat.getMana(targetEntity), 4);
    assertEq(LibCharstat.getLife(targetEntity), 4);

    // Life/mana currents must be capped by their max values in charstat getters
    scopedSystemMock.charstat__setManaCurrent(targetEntity, 100);
    assertEq(LibCharstat.getMana(targetEntity), 4);
    scopedSystemMock.charstat__setLifeCurrent(targetEntity, 100);
    assertEq(LibCharstat.getLife(targetEntity), 4);
  }
}
