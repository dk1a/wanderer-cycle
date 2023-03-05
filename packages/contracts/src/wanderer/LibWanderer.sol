// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { IdentityComponent, ID as IdentityComponentID } from "./IdentityComponent.sol";

library LibWanderer {
  function gainCycleRewards(IUint256Component components, uint256 wandererEntity) internal {
    // TODO very unfinished and hardcoded
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
