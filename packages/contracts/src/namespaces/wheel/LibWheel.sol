// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ActiveWheel } from "./codegen/tables/ActiveWheel.sol";
import { Wheel, WheelData } from "./codegen/tables/Wheel.sol";
import { WheelsCompleted } from "./codegen/tables/WheelsCompleted.sol";
import { IdentityCurrent } from "./codegen/tables/IdentityCurrent.sol";
import { IdentityEarnedTotal } from "./codegen/tables/IdentityEarnedTotal.sol";
import { UniqueIdx_Wheel_Name } from "./codegen/idxs/UniqueIdx_Wheel_Name.sol";

library LibWheel {
  error LibWheel_NameNotFound(string name);
  error LibWheel_InvalidWheelEntity();
  error LibWheel_WheelAlreadyActive(bytes32 cycleEntity);
  error LibWheel_WheelNotActive(bytes32 cycleEntity);
  error LibWheel_InsufficientIdentity(bytes32 wandererEntity, uint256 identityTotal, uint256 identityRequired);

  uint256 constant IDENTITY_INCREMENT = 128;

  function getWheelEntity(string memory name) internal view returns (bytes32 wheelEntity) {
    wheelEntity = UniqueIdx_Wheel_Name.get(name);
    if (wheelEntity == bytes32(0)) {
      revert LibWheel_NameNotFound(name);
    }
  }

  function activateWheel(
    bytes32 wandererEntity,
    bytes32 cycleEntity,
    bytes32 wheelEntity
  ) internal returns (bool isIsolated) {
    WheelData memory wheel = Wheel.get(wheelEntity);
    if (bytes(wheel.name).length == 0) {
      revert LibWheel_InvalidWheelEntity();
    }
    if (ActiveWheel.get(cycleEntity) != bytes32(0)) {
      revert LibWheel_WheelAlreadyActive(cycleEntity);
    }
    if (wheel.totalIdentityRequired > 0) {
      uint256 identityTotal = IdentityEarnedTotal.get(wandererEntity);
      if (identityTotal < wheel.totalIdentityRequired) {
        revert LibWheel_InsufficientIdentity(wandererEntity, identityTotal, wheel.totalIdentityRequired);
      }
    }

    // Set active wheel
    ActiveWheel.set(cycleEntity, wheelEntity);

    return wheel.isIsolated;
  }

  function completeWheel(bytes32 wandererEntity, bytes32 cycleEntity) internal {
    bytes32 wheelEntity = ActiveWheel.get(cycleEntity);
    if (wheelEntity == bytes32(0)) {
      revert LibWheel_WheelNotActive(cycleEntity);
    }

    WheelData memory wheel = Wheel.get(wheelEntity);

    // Get number of completed wheels
    uint32 wheelsCompleted = WheelsCompleted.get(wandererEntity, wheelEntity);

    // Reward identity if charges remain
    if (wheelsCompleted < wheel.charges) {
      rewardIdentity(wandererEntity);
    }
    // Increment completed count
    WheelsCompleted.set(wandererEntity, wheelEntity, wheelsCompleted + 1);
  }

  function rewardIdentity(bytes32 wandererEntity) internal {
    uint256 addition = IDENTITY_INCREMENT;

    IdentityCurrent.set(wandererEntity, IdentityCurrent.get(wandererEntity) + addition);
    IdentityEarnedTotal.set(wandererEntity, IdentityEarnedTotal.get(wandererEntity) + addition);
  }
}
