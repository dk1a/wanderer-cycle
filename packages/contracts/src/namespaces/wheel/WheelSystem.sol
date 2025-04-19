// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { ActiveWheel } from "./codegen/tables/ActiveWheel.sol";
import { Wheel, WheelData } from "./codegen/tables/Wheel.sol";
import { CompletedWheels } from "./codegen/tables/CompletedWheels.sol";
import { IdentityCurrent } from "./codegen/tables/IdentityCurrent.sol";
import { IdentityEarnedTotal } from "./codegen/tables/IdentityEarnedTotal.sol";

import { IDENTITY_INCREMENT } from "./constants.sol";

contract WheelSystem is System {
  error LibWheel_InvalidWheelEntity();
  error LibWheel_WheelAlreadyActive(bytes32 cycleEntity);
  error LibWheel_WheelNotActive(bytes32 cycleEntity);
  error LibWheel_InsufficientIdentity(bytes32 wandererEntity, uint256 identityTotal, uint256 identityRequired);

  function activateWheel(
    bytes32 wandererEntity,
    bytes32 cycleEntity,
    bytes32 wheelEntity
  ) public returns (bool isIsolated) {
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

  function completeWheel(bytes32 wandererEntity, bytes32 cycleEntity) public {
    bytes32 wheelEntity = ActiveWheel.get(cycleEntity);
    if (wheelEntity == bytes32(0)) {
      revert LibWheel_WheelNotActive(cycleEntity);
    }

    // Get number of completed wheels
    uint256 completedWheels = CompletedWheels.length(wandererEntity, wheelEntity);

    // Reward identity if charges remain
    WheelData memory wheel = Wheel.get(wheelEntity);
    if (completedWheels < wheel.charges) {
      rewardIdentity(wandererEntity);
    }
    // Append the cycle to the list of wheel completions
    CompletedWheels.push(wandererEntity, wheelEntity, cycleEntity);
  }

  function rewardIdentity(bytes32 wandererEntity) public {
    uint256 addition = IDENTITY_INCREMENT;

    IdentityCurrent.set(wandererEntity, IdentityCurrent.get(wandererEntity) + addition);
    IdentityEarnedTotal.set(wandererEntity, IdentityEarnedTotal.get(wandererEntity) + addition);
  }
}
