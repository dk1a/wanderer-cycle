// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { ActiveWheel } from "./codegen/tables/ActiveWheel.sol";
import { Wheel, WheelData } from "./codegen/tables/Wheel.sol";
import { CompletedWheelHistory } from "./codegen/tables/CompletedWheelHistory.sol";
import { CompletedWheelCount } from "./codegen/tables/CompletedWheelCount.sol";
import { IdentityCurrent } from "./codegen/tables/IdentityCurrent.sol";
import { IdentityEarnedTotal } from "./codegen/tables/IdentityEarnedTotal.sol";

import { IDENTITY_INCREMENT } from "./constants.sol";

contract WheelSystem is System {
  error WheelSystem_InvalidWheelEntity();
  error WheelSystem_WheelAlreadyActive(bytes32 cycleEntity);
  error WheelSystem_WheelNotActive(bytes32 cycleEntity);
  error WheelSystem_NotEnoughTotalIdentity(bytes32 wandererEntity, uint256 totalIdentity, uint256 requiredIdentity);
  error WheelSystem_NotEnoughCurrentIdentity(bytes32 wandererEntity, uint256 currentIdentity, uint256 requiredIdentity);

  function activateWheel(
    bytes32 wandererEntity,
    bytes32 cycleEntity,
    bytes32 wheelEntity
  ) public returns (bool isIsolated) {
    WheelData memory wheel = Wheel.get(wheelEntity);
    if (bytes(wheel.name).length == 0) {
      revert WheelSystem_InvalidWheelEntity();
    }
    if (ActiveWheel.get(cycleEntity) != bytes32(0)) {
      revert WheelSystem_WheelAlreadyActive(cycleEntity);
    }
    if (wheel.totalIdentityRequired > 0) {
      uint256 identityTotal = IdentityEarnedTotal.get(wandererEntity);
      if (identityTotal < wheel.totalIdentityRequired) {
        revert WheelSystem_NotEnoughTotalIdentity(wandererEntity, identityTotal, wheel.totalIdentityRequired);
      }
    }

    // Set active wheel
    ActiveWheel.set(cycleEntity, wheelEntity);

    return wheel.isIsolated;
  }

  function completeWheel(bytes32 wandererEntity, bytes32 cycleEntity) public {
    bytes32 wheelEntity = ActiveWheel.get(cycleEntity);
    if (wheelEntity == bytes32(0)) {
      revert WheelSystem_WheelNotActive(cycleEntity);
    }

    // Get number of completed wheels
    uint256 completedWheelCount = CompletedWheelCount.get(wandererEntity, wheelEntity);

    // Reward identity if charges remain
    WheelData memory wheel = Wheel.get(wheelEntity);
    if (completedWheelCount < wheel.charges) {
      rewardIdentity(wandererEntity);
    }
    // Increment wheel completion count
    CompletedWheelCount.set(wandererEntity, wheelEntity, completedWheelCount + 1);
    // Update cycle owner's completion history
    CompletedWheelHistory.push(wandererEntity, cycleEntity);
  }

  function rewardIdentity(bytes32 wandererEntity) public {
    uint256 addition = IDENTITY_INCREMENT;

    IdentityCurrent.set(wandererEntity, IdentityCurrent.get(wandererEntity) + addition);
    IdentityEarnedTotal.set(wandererEntity, IdentityEarnedTotal.get(wandererEntity) + addition);
  }

  function subtractIdentity(bytes32 wandererEntity, uint256 subtract) public {
    uint256 current = IdentityCurrent.get(wandererEntity);
    if (current < subtract) {
      revert WheelSystem_NotEnoughCurrentIdentity(wandererEntity, current, subtract);
    }
    IdentityCurrent.set(wandererEntity, current - subtract);
  }
}
