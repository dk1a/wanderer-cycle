// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { LibRNG } from "./LibRNG.sol";

contract RNGSystem is System {
  function requestRandomness(bytes32 requestOwnerEntity) public returns (bytes32 requestId) {
    return LibRNG.requestRandomness(requestOwnerEntity);
  }

  function removeRequest(bytes32 requestOwnerEntity, bytes32 requestId) public {
    LibRNG.removeRequest(requestOwnerEntity, requestId);
  }
}
