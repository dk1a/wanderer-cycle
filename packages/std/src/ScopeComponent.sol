// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { Uint256Component } from "@latticexyz/std-contracts/src/components/Uint256Component.sol";

abstract contract ScopeComponent is Uint256Component {
    constructor(address world, uint256 ID) Uint256Component(world, ID) {}
}