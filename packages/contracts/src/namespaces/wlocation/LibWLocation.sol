// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SmartObjectFramework } from "../evefrontier/SmartObjectFramework.sol";

import { IWLocationSmartObject } from "./IWLocationSmartObject.sol";

library LibWLocation {
  function canEnter(address locationAddress, bytes32 entrantEntity) internal view returns (bool) {
    IWLocationSmartObject location = IWLocationSmartObject(locationAddress);
    return location.canEnter(entrantEntity);
  }
}
