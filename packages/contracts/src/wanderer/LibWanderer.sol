// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Identity, PreviousCycle, ActiveWheel, DefaultWheel, Wheel, WheelData, WheelsCompleted } from "../codegen/index.sol";

library LibWanderer {
  function gainCycleRewards(bytes32 wandererEntity) internal {
    bytes32 prevCycleEntity = PreviousCycle.get(wandererEntity);

    // get last wheel entity
    bytes32 wheelEntity = ActiveWheel.get(prevCycleEntity);

    // and its data
    WheelData memory wheel = Wheel.get(wheelEntity);

    // get number of completed wheels
    uint32 wheelsCompletedEntity = WheelsCompleted.get(wandererEntity, wheelEntity);

    uint32 wheelsCompleted = 0;

    // reward identity if charges remain
    if (wheelsCompleted < wheel.charges) {
      _rewardIdentity(wandererEntity);
    }
    // increment completed count
    WheelsCompleted.set(wandererEntity, wheelEntity, wheelsCompleted + 1);
  }

  function _rewardIdentity(bytes32 wandererEntity) private {
    uint32 currentIdentity;
    if (Identity.get(wandererEntity) == uint32(0)) {
      currentIdentity = 0;
    } else {
      currentIdentity = Identity.get(wandererEntity);
    }
    Identity.set(wandererEntity, currentIdentity + 128);
  }
}
