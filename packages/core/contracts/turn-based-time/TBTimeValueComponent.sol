// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ValueComponent } from "../scoped-value/ValueComponent.sol";

uint256 constant ID = uint256(keccak256("component.TBTimeValue"));

contract TBTimeValueComponent is ValueComponent {
  constructor(address _world) ValueComponent(_world, ID) {}
}