// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import { SingletonID } from "../SingletonID.sol";

import { WheelComponent, ID as WheelComponentID, WheelData } from "../wheel/WheelComponent.sol";
import { DefaultWheelComponent, ID as DefaultWheelComponentID } from "../wheel/DefaultWheelComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

library LibInitWheel {
  error GuisePrototypeInitSystem__InvalidSkill();

  function init(IWorld world) internal {
    uint256 wheelEntity = add(
      world,
      "Wheel of Attainment",
      WheelData({ totalIdentityRequired: 0, charges: 3, isIsolated: false })
    );

    DefaultWheelComponent defaultWheel = DefaultWheelComponent(
      getAddressById(world.components(), DefaultWheelComponentID)
    );
    defaultWheel.set(SingletonID, wheelEntity);

    add(world, "Wheel of Isolation", WheelData({ totalIdentityRequired: 128, charges: 4, isIsolated: true }));
  }

  function add(IWorld world, string memory name, WheelData memory wheelData) internal returns (uint256 entity) {
    IUint256Component components = world.components();
    WheelComponent wheelComp = WheelComponent(getAddressById(components, WheelComponentID));
    NameComponent nameComp = NameComponent(getAddressById(components, NameComponentID));

    entity = world.getUniqueEntityId();

    wheelComp.set(entity, wheelData);
    nameComp.set(entity, name);
  }
}
