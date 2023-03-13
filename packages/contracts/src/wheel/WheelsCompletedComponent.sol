// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Uint32BareComponent } from "std-contracts/components/Uint32BareComponent.sol";

/**
 * @dev wheelsCompletedEntity = hashed(wandererEntity, wheelEntity)
 */
function getWheelsCompletedEntity(uint256 wandererEntity, uint256 wheelEntity) pure returns (uint256) {
  return uint256(keccak256(abi.encode(wandererEntity, wheelEntity)));
}

uint256 constant ID = uint256(keccak256("component.WheelsCompleted"));

contract WheelsCompletedComponent is Uint32BareComponent {
  constructor(address world) Uint32BareComponent(world, ID) {}
}
