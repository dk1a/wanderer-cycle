// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ScopeComponent } from "@dk1a/solecslib/contracts/scoped-value/ScopeComponent.sol";

uint256 constant ID = uint256(keccak256("component.StatmodScope"));

contract StatmodScopeComponent is ScopeComponent {
  constructor(address _world) ScopeComponent(_world, ID) {}
}
