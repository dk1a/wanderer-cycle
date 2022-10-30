// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { ScopeComponent } from "@wanderer-cycle/std/contracts/ScopeComponent.sol";

uint256 constant ID = uint256(keccak256('component.TBScopeComponent'));

contract TBScopeComponent is ScopeComponent {
    constructor(address world) ScopeComponent(world, ID) {}
}