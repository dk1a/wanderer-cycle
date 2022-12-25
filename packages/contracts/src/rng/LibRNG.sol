// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { RNGPrecommit, RNGPrecommitComponent, ID as RNGPrecommitComponentID } from "./RNGPrecommitComponent.sol";

library LibRNG {
  error LibRNG__InvalidPrecommit();

  uint256 constant WAIT_BLOCKS = 1;

  function requestRandomness(
    IWorld world,
    bytes memory data
  ) internal returns (uint256 requestId) {
    requestId = world.getUniqueEntityId();
    
    RNGPrecommitComponent(
      getAddressById(world.components(), RNGPrecommitComponentID)
    ).set(requestId, RNGPrecommit({
      blocknumber: block.number + WAIT_BLOCKS,
      data: data
    }));

    return requestId;
  }

  function getRandomness(
    IUint256Component components,
    uint256 requestId
  ) internal view returns (uint256) {
    RNGPrecommit memory precommit = getPrecommit(components, requestId);

    if (!isValid(precommit)) revert LibRNG__InvalidPrecommit();

    return uint256(blockhash(precommit.blocknumber));
  }

  function getPrecommit(
    IUint256Component components,
    uint256 requestId
  ) internal view returns (RNGPrecommit memory) {
    return RNGPrecommitComponent(
      getAddressById(components, RNGPrecommitComponentID)
    ).getValue(requestId);
  }

  function isValid(RNGPrecommit memory precommit) internal view returns (bool) {
    // must be initialized
    return precommit.blocknumber != 0
    // and past the precommitted-to-block
      && precommit.blocknumber < block.number
    // and not too far past it because blockhash only works for 256 most recent blocks
      && !isOverBlockLimit(precommit);
  }

  function isOverBlockLimit(RNGPrecommit memory precommit) internal view returns (bool) {
    return block.number > precommit.blocknumber + 256;
  }
}