// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";
import { BaseTest } from "./BaseTest.t.sol";

import { randomnessSystem } from "../src/namespaces/rng/codegen/systems/RandomnessSystemLib.sol";
import { LibSOFClass } from "../src/namespaces/common/LibSOFClass.sol";
import { LibRNG } from "../src/namespaces/rng/LibRNG.sol";
import { RNGPrecommit, RNGRequestOwner } from "../src/namespaces/rng/codegen/index.sol";

contract RandomnessSystemTest is BaseTest {
  bytes32 requestOwnerEntity;

  function setUp() public virtual override {
    super.setUp();

    vm.startPrank(deployer);
    requestOwnerEntity = LibSOFClass.instantiate("test", deployer);
    vm.stopPrank();
  }

  function testRevertUnscoped() public {
    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, requestOwnerEntity, emptySystemId)
    );
    emptySystemMock.rng__requestRandomness(requestOwnerEntity);

    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, requestOwnerEntity, emptySystemId)
    );
    emptySystemMock.rng__removeRequest(requestOwnerEntity, hex"1234");
  }

  function test_getRandomness() public {
    bytes32 requestId = scopedSystemMock.rng__requestRandomness(requestOwnerEntity);
    vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
    uint256 randomness = LibRNG.getRandomness(requestOwnerEntity, requestId);
    assertGt(randomness, 0);
    assertEq(RNGRequestOwner.get(requestId), requestOwnerEntity);
  }

  function test_getRandomness_revert_NotRequestOwner() public {
    bytes32 requestId = scopedSystemMock.rng__requestRandomness(requestOwnerEntity);

    vm.expectRevert(LibRNG.LibRNG_NotRequestOwner.selector);
    scopedSystemMock.rng__getRandomness(emptyEntity, requestId);
  }

  function test_getRandomness_revert_sameBlock() public {
    bytes32 requestId = scopedSystemMock.rng__requestRandomness(requestOwnerEntity);

    vm.expectRevert(LibRNG.LibRNG_InvalidPrecommit.selector);
    scopedSystemMock.rng__getRandomness(requestOwnerEntity, requestId);
  }

  function test_getRandomness_revert_tooLate() public {
    bytes32 requestId = scopedSystemMock.rng__requestRandomness(requestOwnerEntity);

    vm.roll(block.number + LibRNG.WAIT_BLOCKS + 256 + 1);
    vm.expectRevert(LibRNG.LibRNG_InvalidPrecommit.selector);
    scopedSystemMock.rng__getRandomness(requestOwnerEntity, requestId);
  }

  // basic test for different base blocknumbers
  function test_requestRandomness_blocknumbers(uint32 blocknumber) public {
    vm.assume(blocknumber != 0);
    vm.roll(blocknumber);
    bytes32 requestId = scopedSystemMock.rng__requestRandomness(requestOwnerEntity);

    uint256 precommit = RNGPrecommit.get(requestId);
    assertEq(precommit, blocknumber + LibRNG.WAIT_BLOCKS);
    assertEq(RNGRequestOwner.get(requestId), requestOwnerEntity);

    uint256 newBlocknumber = uint256(blocknumber) + 10;
    vm.roll(newBlocknumber);
    precommit = RNGPrecommit.get(requestId);
    assertLt(precommit, newBlocknumber);
    assertEq(RNGRequestOwner.get(requestId), requestOwnerEntity);
    assertTrue(LibRNG.isValid(precommit));
  }

  // thorough validity test for the possible offsets
  function test_requestRandomness_validity() public {
    uint256 initBlock = 1;
    vm.roll(initBlock);

    bytes32 requestId = scopedSystemMock.rng__requestRandomness(requestOwnerEntity);
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
   uint256 requestId = randomnessSystem.requestRandomness(world, '');

   vm.roll(block.number + 1);
   vm.expectRevert(LibRNG.LibRNG__InvalidPrecommit.selector);
   scopedSystemMock.rng__getRandomness(requestId);
 }*/
