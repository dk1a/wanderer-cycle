// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { SystemCallbackBareComponent, SystemCallback, executeSystemCallback } from "std-contracts/components/SystemCallbackBareComponent.sol";

uint256 constant ID = uint256(keccak256("component.DurationOnEnd"));

contract DurationOnEndComponent is SystemCallbackBareComponent {
  constructor(address world) SystemCallbackBareComponent(world, ID) {}
}
