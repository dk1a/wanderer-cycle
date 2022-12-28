// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BoolBareComponent } from "std-contracts/components/BoolBareComponent.sol";

uint256 constant ID = uint256(keccak256("component.MapPrototype"));

contract MapPrototypeComponent is BoolBareComponent {
  constructor(address world) BoolBareComponent(world, ID) {}
}