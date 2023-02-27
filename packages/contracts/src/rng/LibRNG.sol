// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { RNGPrecommit, RNGPrecommitComponent, ID as RNGPrecommitComponentID } from "./RNGPrecommitComponent.sol";

/// @dev Simple blockhash rng.
/// Get requestId from `requestRandomness`, then after `WAIT_BLOCKS` call `getRandomness` with that requestId.
/// Use `data` to lock relevant resources to avoid costless/infinite rng retries.
/// Do not reuse the same requestId, otherwise it can be predictable.
///
/// on-chain try+discard - solved with precommits to future block numbers.
/// 256 past blocks limit - ignored. Build UX around it.
/// MEV - ignored. Don't use this for high stakes.
///
/// TODO consider prevrandao, VRF, eip-2935
library LibRNG {
  error LibRNG__InvalidPrecommit();

  // TODO 0 wait allows 2 txs in a row really fast and is great during local dev, but not exactly safe
  // (note that this does not allow same-block retrieval - you can't get current blockhash)
  uint256 constant WAIT_BLOCKS = 0;

  function requestRandomness(IWorld world, bytes memory data) internal returns (uint256 requestId) {
    requestId = world.getUniqueEntityId();

    RNGPrecommitComponent(getAddressById(world.components(), RNGPrecommitComponentID)).set(
      requestId,
      RNGPrecommit({ blocknumber: block.number + WAIT_BLOCKS, data: data })
    );

    return requestId;
  }

  function getRandomness(
    IUint256Component components,
    uint256 requestId
  ) internal view returns (uint256 randomness, bytes memory data) {
    RNGPrecommit memory precommit = getPrecommit(components, requestId);

    if (!isValid(precommit)) revert LibRNG__InvalidPrecommit();

    randomness = uint256(blockhash(precommit.blocknumber));
    data = precommit.data;
  }

  function getPrecommit(IUint256Component components, uint256 requestId) internal view returns (RNGPrecommit memory) {
    return RNGPrecommitComponent(getAddressById(components, RNGPrecommitComponentID)).getValue(requestId);
  }

  function isValid(RNGPrecommit memory precommit) internal view returns (bool) {
    return
      // must be initialized
      precommit.blocknumber != 0 &&
      // and past the precommitted-to-block
      precommit.blocknumber < block.number &&
      // and not too far past it because blockhash only works for 256 most recent blocks
      !isOverBlockLimit(precommit);
  }

  function isOverBlockLimit(RNGPrecommit memory precommit) internal view returns (bool) {
    return block.number > precommit.blocknumber + 256;
  }
}
