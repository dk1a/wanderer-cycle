// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { ActiveCyclePreviousComponent, ID as ActiveCyclePreviousComponentID } from "../cycle/ActiveCyclePreviousComponent.sol";
import { ActiveWheelComponent, ID as ActiveWheelComponentID } from "../wheel/ActiveWheelComponent.sol";
import { WheelComponent, ID as WheelComponentID, WheelData } from "../wheel/WheelComponent.sol";
import { WheelsCompletedComponent, ID as WheelsCompletedComponentID, getWheelsCompletedEntity } from "../wheel/WheelsCompletedComponent.sol";
import { IdentityComponent, ID as IdentityComponentID } from "./IdentityComponent.sol";

library LibWanderer {
  function gainCycleRewards(IUint256Component components, uint256 wandererEntity) internal {
    ActiveCyclePreviousComponent activeCyclePreviousComp = ActiveCyclePreviousComponent(
      getAddressById(components, ActiveCyclePreviousComponentID)
    );
    uint256 prevCycleEntity = activeCyclePreviousComp.getValue(wandererEntity);

    // get last wheel entity
    ActiveWheelComponent activeWheelComp = ActiveWheelComponent(getAddressById(components, ActiveWheelComponentID));
    uint256 wheelEntity = activeWheelComp.getValue(prevCycleEntity);
    // and its data
    WheelComponent wheelComp = WheelComponent(getAddressById(components, WheelComponentID));
    WheelData memory wheel = wheelComp.getValue(wheelEntity);

    // get number of completed wheels
    uint256 wheelsCompletedEntity = getWheelsCompletedEntity(wandererEntity, wheelEntity);
    WheelsCompletedComponent wheelsCompletedComp = WheelsCompletedComponent(
      getAddressById(components, WheelsCompletedComponentID)
    );
    uint32 wheelsCompleted = 0;
    if (wheelsCompletedComp.has(wheelsCompletedEntity)) {
      wheelsCompleted = wheelsCompletedComp.getValue(wheelsCompletedEntity);
    }

    // reward identity if charges remain
    if (wheelsCompleted < wheel.charges) {
      _rewardIdentity(components, wandererEntity);
    }
    // increment completed count
    wheelsCompletedComp.set(wheelsCompletedEntity, wheelsCompleted + 1);
  }

  function _rewardIdentity(IUint256Component components, uint256 wandererEntity) private {
    IdentityComponent identityComponent = IdentityComponent(getAddressById(components, IdentityComponentID));
    uint32 currentIdentity;
    if (!identityComponent.has(wandererEntity)) {
      currentIdentity = 0;
    } else {
      currentIdentity = identityComponent.getValue(wandererEntity);
    }
    identityComponent.set(wandererEntity, currentIdentity + 128);
  }
}
