// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { StringBareComponent } from "std-contracts/components/StringBareComponent.sol";

uint256 constant ID = uint256(keccak256("component.ReverseHashName"));

contract ReverseHashNameComponent is StringBareComponent {
  constructor(address world) StringBareComponent(world, ID) {}
}