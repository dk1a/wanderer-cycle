// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { UniqueIdx_Wheel_Name } from "./codegen/idxs/UniqueIdx_Wheel_Name.sol";

library LibWheel {
  error LibWheel_NameNotFound(string name);

  function getWheelEntity(string memory name) internal view returns (bytes32 wheelEntity) {
    wheelEntity = UniqueIdx_Wheel_Name.get(name);
    if (wheelEntity == bytes32(0)) {
      revert LibWheel_NameNotFound(name);
    }
  }
}
