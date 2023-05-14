// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { RNGPrecommitComponent, ID as RNGPrecommitComponentID } from "./RNGPrecommitComponent.sol";
import { RNGRequestOwnerComponent, ID as RNGRequestOwnerComponentID } from "./RNGRequestOwnerComponent.sol";

/// @dev Simple blockhash rng.
/// Get requestId from `requestRandomness`, then after `WAIT_BLOCKS` call `getRandomness` with that requestId.
/// Do not reuse the same requestId, otherwise it can be predictable.
///
/// on-chain try+discard - solved with precommits to future block numbers.
/// 256 past blocks limit - ignored. Build UX around it.
/// MEV - ignored. Don't use this for high stakes.
///
/// TODO consider prevrandao, VRF, eip-2935
library LibRNG {
  error LibRNG__InvalidPrecommit();
  error LibRNG__NotRequestOwner();

  // TODO 0 wait allows 2 txs in a row really fast and is great during local dev, but not exactly safe
  // (note that this does not allow same-block retrieval - you can't get current blockhash)
  uint256 constant WAIT_BLOCKS = 0;

  function requestRandomness(IWorld world, uint256 requestOwnerEntity) internal returns (uint256 requestId) {
    requestId = world.getUniqueEntityId();

    RNGPrecommitComponent(getAddressById(world.components(), RNGPrecommitComponentID)).set(
      requestId,
      block.number + WAIT_BLOCKS
    );

    RNGRequestOwnerComponent(getAddressById(world.components(), RNGRequestOwnerComponentID)).set(
      requestId,
      requestOwnerEntity
    );

    return requestId;
  }

  function getRandomness(
    IUint256Component components,
    uint256 requestOwnerEntity,
    uint256 requestId
  ) internal view returns (uint256 randomness) {
    if (requestOwnerEntity != getRequestOwner(components, requestId)) {
      revert LibRNG__NotRequestOwner();
    }

    uint256 precommit = getPrecommit(components, requestId);

    if (!isValid(precommit)) revert LibRNG__InvalidPrecommit();

    return uint256(blockhash(precommit));
  }

  /** Check permission and remove the request */
  function removeRequest(IUint256Component components, uint256 requestOwnerEntity, uint256 requestId) internal {
    if (requestOwnerEntity != getRequestOwner(components, requestId)) {
      revert LibRNG__NotRequestOwner();
    }
    RNGPrecommitComponent(getAddressById(components, RNGPrecommitComponentID)).remove(requestId);
    RNGRequestOwnerComponent(getAddressById(components, RNGRequestOwnerComponentID)).remove(requestId);
  }

  function getPrecommit(IUint256Component components, uint256 requestId) internal view returns (uint256 precommit) {
    return RNGPrecommitComponent(getAddressById(components, RNGPrecommitComponentID)).getValue(requestId);
  }

  function getRequestOwner(
    IUint256Component components,
    uint256 requestId
  ) internal view returns (uint256 requestOwnerEntity) {
    return RNGRequestOwnerComponent(getAddressById(components, RNGRequestOwnerComponentID)).getValue(requestId);
  }

  function isValid(uint256 precommit) internal view returns (bool) {
    return
      // must be initialized
      precommit != 0 &&
      // and past the precommitted-to-block
      precommit < block.number &&
      // and not too far past it because blockhash only works for 256 most recent blocks
      !isOverBlockLimit(precommit);
  }

  function isOverBlockLimit(uint256 precommit) internal view returns (bool) {
    return block.number > precommit + 256;
  }
}
