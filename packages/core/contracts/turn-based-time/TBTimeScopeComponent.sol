// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ScopeComponent } from "../scoped-value/ScopeComponent.sol";

uint256 constant ID = uint256(keccak256("component.TBTimeScope"));

contract TBTimeScopeComponent is ScopeComponent {
  constructor(address _world) ScopeComponent(_world, ID) {}
}