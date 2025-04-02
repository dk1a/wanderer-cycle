// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { Wheel, WheelData } from "./codegen/tables/Wheel.sol";

library LibInitWheel {
  function init() internal {
    _add(WheelData({ totalIdentityRequired: 0, charges: 3, isIsolated: false, name: "Wheel of Attainment" }));
    _add(WheelData({ totalIdentityRequired: 128, charges: 4, isIsolated: true, name: "Wheel of Isolation" }));
  }

  function _add(WheelData memory wheelData) private returns (bytes32 entity) {
    entity = getUniqueEntity();

    Wheel.set(entity, wheelData);
  }
}
