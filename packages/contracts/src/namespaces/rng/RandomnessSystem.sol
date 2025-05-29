// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SmartObjectFramework } from "../evefrontier/SmartObjectFramework.sol";

import { LibRNG } from "./LibRNG.sol";

contract RandomnessSystem is SmartObjectFramework {
  function requestRandomness(bytes32 requestOwnerEntity) public context returns (bytes32 requestId) {
    _requireEntityLeaf(uint256(requestOwnerEntity));

    return LibRNG.requestRandomness(requestOwnerEntity);
  }

  function removeRequest(bytes32 requestOwnerEntity, bytes32 requestId) public context {
    _requireEntityLeaf(uint256(requestOwnerEntity));

    LibRNG.removeRequest(requestOwnerEntity, requestId);
  }

  function getRandomness(bytes32 requestOwnerEntity, bytes32 requestId) public view returns (uint256 randomness) {
    return LibRNG.getRandomness(requestOwnerEntity, requestId);
  }
}
