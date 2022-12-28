// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ID } from "./MapPrototypeComponent.sol";

library MapPrototypes {
  uint256 constant GLOBAL_BASIC = uint256(keccak256(abi.encode(ID, 'Global Basic')));
}