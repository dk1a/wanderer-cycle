// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

import { Wheel, DefaultWheel, Name, WheelData } from "../codegen/Tables.sol";

library LibInitWheel {
  function init() internal {
    bytes32 wheelEntity = _add(
      "Wheel of Attainment",
      WheelData({ totalIdentityRequired: 0, charges: 3, isIsolated: false })
    );

    DefaultWheel.set(wheelEntity);

    _add("Wheel of Isolation", WheelData({ totalIdentityRequired: 128, charges: 4, isIsolated: true }));
  }

  function _add(string memory name, WheelData memory wheelData) private returns (bytes32 entity) {
    entity = getUniqueEntity();

    Wheel.set(entity, wheelData);
    Name.set(entity, name);
  }
}
