// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ValueComponent } from "@dk1a/solecslib/contracts/scoped-value/ValueComponent.sol";

uint256 constant ID = uint256(keccak256("component.DurationValue"));

contract DurationValueComponent is ValueComponent {
  constructor(address world) ValueComponent(world, ID) {}
}