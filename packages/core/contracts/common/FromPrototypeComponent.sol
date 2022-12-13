// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { FromPrototypeComponent as _FromPrototypeComponent } from "@dk1a/solecslib/contracts/prototype/FromPrototypeComponent.sol";

uint256 constant ID = uint256(keccak256("component.FromPrototype"));

contract FromPrototypeComponent is _FromPrototypeComponent {
  constructor(address world) _FromPrototypeComponent(world, ID) {}
}