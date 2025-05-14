// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { rNGSystem } from "../src/namespaces/rng/codegen/systems/RNGSystemLib.sol";
import { LibRNG } from "../src/namespaces/rng/LibRNG.sol";
import { RNGPrecommit, RNGRequestOwner } from "../src/namespaces/rng/codegen/index.sol";
import { BaseTest } from "./BaseTest.t.sol";
import { TestSystem } from "./TestSystem.sol";

contract RNGTestSystem is TestSystem {
  constructor(address worldAddress) TestSystem(worldAddress) {}

  function getRandomness(bytes32 requestOwner, bytes32 requestId) public view {
    LibRNG.getRandomness(requestOwner, requestId);
  }
}

contract LibRNGTest is BaseTest {
  RNGTestSystem rngTestSystem;

  function setUp() public virtual override {
    super.setUp();

    rngTestSystem = new RNGTestSystem(worldAddress);
  }

  function _initEntity() internal returns (bytes32 requestOwner, bytes32 notOwner) {
    requestOwner = getUniqueEntity();
    notOwner = getUniqueEntity();
  }

  function test_getRandomness() public {
    (bytes32 requestOwner, ) = _initEntity();
    bytes32 requestId = rNGSystem.requestRandomness(requestOwner);
    vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
    uint256 randomness = LibRNG.getRandomness(requestOwner, requestId);
    assertGt(randomness, 0);
    assertEq(RNGRequestOwner.get(requestId), requestOwner);
  }

  function test_getRandomness_revert_NotRequestOwner() public {
    (bytes32 requestOwner, bytes32 notOwner) = _initEntity();

    bytes32 requestId = rNGSystem.requestRandomness(requestOwner);

    vm.expectRevert(LibRNG.LibRNG_NotRequestOwner.selector);
    rngTestSystem.getRandomness(notOwner, requestId);
  }

  function test_getRandomness_revert_sameBlock() public {
    (bytes32 requestOwner, ) = _initEntity();

    bytes32 requestId = rNGSystem.requestRandomness(requestOwner);

    vm.expectRevert(LibRNG.LibRNG_InvalidPrecommit.selector);
    rngTestSystem.getRandomness(requestOwner, requestId);
  }

  function test_getRandomness_revert_tooLate() public {
    (bytes32 requestOwner, ) = _initEntity();

    bytes32 requestId = rNGSystem.requestRandomness(requestOwner);

    vm.roll(block.number + LibRNG.WAIT_BLOCKS + 256 + 1);
    vm.expectRevert(LibRNG.LibRNG_InvalidPrecommit.selector);
    rngTestSystem.getRandomness(requestOwner, requestId);
  }

  // basic test for different base blocknumbers
  function test_requestRandomness_blocknumbers(uint32 blocknumber) public {
    (bytes32 requestOwner, ) = _initEntity();

    vm.assume(blocknumber != 0);
    vm.roll(blocknumber);
    bytes32 requestId = rNGSystem.requestRandomness(requestOwner);

    uint256 precommit = RNGPrecommit.get(requestId);
    assertEq(precommit, blocknumber + LibRNG.WAIT_BLOCKS);
    assertEq(RNGRequestOwner.get(requestId), requestOwner);

    uint256 newBlocknumber = uint256(blocknumber) + 10;
    vm.roll(newBlocknumber);
    precommit = RNGPrecommit.get(requestId);
    assertLt(precommit, newBlocknumber);
    assertEq(RNGRequestOwner.get(requestId), requestOwner);
    assertTrue(LibRNG.isValid(precommit));
  }

  // thorough validity test for the possible offsets
  function test_requestRandomness_validity() public {
    (bytes32 requestOwner, ) = _initEntity();

    uint256 initBlock = 1;
    vm.roll(initBlock);

    bytes32 requestId = rNGSystem.requestRandomness(requestOwner);
    uint256 precommit = RNGPrecommit.get(requestId);

    for (uint256 i = initBlock; i < initBlock + 270; i++) {
      vm.roll(i);
      if (i <= initBlock + LibRNG.WAIT_BLOCKS) {
        assertFalse(LibRNG.isValid(precommit));
        assertEq(uint256(blockhash(precommit)), 0);
      } else if (i <= initBlock + LibRNG.WAIT_BLOCKS + 256) {
        assertTrue(LibRNG.isValid(precommit));
        assertFalse(LibRNG.isOverBlockLimit(precommit));
        assertGt(uint256(blockhash(precommit)), 0);
      } else {
        assertFalse(LibRNG.isValid(precommit));
        assertTrue(LibRNG.isOverBlockLimit(precommit));
        assertEq(uint256(blockhash(precommit)), 0);
      }
    }
  }
}

/* TODO not relevant while WAIT_BLOCKS = 0
 function test_getRandomness_revert_tooEarly() public {
   uint256 requestId = rNGSystem.requestRandomness(world, '');

   vm.roll(block.number + 1);
   vm.expectRevert(LibRNG.LibRNG__InvalidPrecommit.selector);
   revertHelper.getRandomness(requestId);
 }*/
