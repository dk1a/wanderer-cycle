// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BoolBareComponent } from "std-contracts/components/BoolBareComponent.sol";

uint256 constant ID = uint256(keccak256("component.Wanderer"));

/// @title Flag entity as a wanderer
contract WandererComponent is BoolBareComponent {
  constructor(address world) BoolBareComponent(world, ID) {}
}