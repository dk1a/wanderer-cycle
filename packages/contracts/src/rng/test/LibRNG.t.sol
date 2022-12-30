// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";

import { BaseTest } from "../../BaseTest.sol";

import { LibRNG, RNGPrecommit } from "../LibRNG.sol";

contract GetRandomnessRevertHelper {
  function getRandomness(
    IUint256Component components,
    uint256 requestId
  ) public view {
    LibRNG.getRandomness(components, requestId);
  }
}

contract LibRNGTest is BaseTest {
  GetRandomnessRevertHelper revertHelper;

  function setUp() public virtual override {
    super.setUp();

    revertHelper = new GetRandomnessRevertHelper();
  }

  function testGetRandomness() public {
    uint256 requestId = LibRNG.requestRandomness(world, '');
    vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
    uint256 randomness = LibRNG.getRandomness(components, requestId);
    assertGt(randomness, 0);
  }

  function testGetRandomness__InvalidSameBlock() public {
    uint256 requestId = LibRNG.requestRandomness(world, '');

    vm.expectRevert(LibRNG.LibRNG__InvalidPrecommit.selector);
    revertHelper.getRandomness(components, requestId);
  }

  function testGetRandomness__InvalidNextBlock() public {
    uint256 requestId = LibRNG.requestRandomness(world, '');

    vm.roll(block.number + 1);
    vm.expectRevert(LibRNG.LibRNG__InvalidPrecommit.selector);
    revertHelper.getRandomness(components, requestId);
  }

  function testGetRandomness__InvalidLateBlock() public {
    uint256 requestId = LibRNG.requestRandomness(world, '');

    vm.roll(block.number + LibRNG.WAIT_BLOCKS + 256 + 1);
    vm.expectRevert(LibRNG.LibRNG__InvalidPrecommit.selector);
    revertHelper.getRandomness(components, requestId);
  }

  // basic test for different base blocknumbers
  function testRequestRandomnessBlocknumbers(uint32 blocknumber) public {
    vm.roll(blocknumber);
    uint256 requestId = LibRNG.requestRandomness(world, abi.encode(42));

    RNGPrecommit memory precommit = LibRNG.getPrecommit(components, requestId);
    assertGt(precommit.blocknumber, blocknumber);
    assertEq(precommit.data, abi.encode(42));

    uint256 newBlocknumber = uint256(blocknumber) + 10;
    vm.roll(newBlocknumber);
    precommit = LibRNG.getPrecommit(components, requestId);
    assertLt(precommit.blocknumber, newBlocknumber);
    assertEq(precommit.data, abi.encode(42));
    assertTrue(LibRNG.isValid(precommit));
  }

  // thorough validity test for the possible offsets
  function testRequestRandomnessValidity() public {
    uint256 initBlock = 1;
    vm.roll(initBlock);

    uint256 requestId = LibRNG.requestRandomness(world, abi.encode(42));
    RNGPrecommit memory precommit = LibRNG.getPrecommit(components, requestId);

    for (uint256 i = initBlock; i < initBlock + 270; i++) {
      vm.roll(i);
      if (i <= initBlock + LibRNG.WAIT_BLOCKS) {
        assertFalse(LibRNG.isValid(precommit));
        assertEq(uint256(blockhash(precommit.blocknumber)), 0);
      } else if (i <= initBlock + LibRNG.WAIT_BLOCKS + 256) {
        assertTrue(LibRNG.isValid(precommit));
        assertFalse(LibRNG.isOverBlockLimit(precommit));
        assertNotEq(uint256(blockhash(precommit.blocknumber)), 0);
      } else {
        assertFalse(LibRNG.isValid(precommit));
        assertTrue(LibRNG.isOverBlockLimit(precommit));
        assertEq(uint256(blockhash(precommit.blocknumber)), 0);
      }
    }
  }
}