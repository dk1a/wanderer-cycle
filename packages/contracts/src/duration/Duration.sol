// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { DurationValue, DurationValueData, DurationValueTableId, DurationIdxList, DurationIdxMap } from "../codegen/index.sol";

library Duration {
  error Duration_IncreaseByZero();
  error Duration_EntityAbsent();

  /**
   * Increase duration for a specific key set
   * @return isUpdate true if an existing value was increased; false if a new value was set
   */
  function increase(
    bytes32 targetEntity,
    bytes32 applicationEntity,
    bytes32 applicationType,
    DurationValueData memory duration
  ) internal returns (bool isUpdate) {
    if (duration.timeValue == 0) {
      revert Duration_IncreaseByZero();
    }

    uint256 storedValue = DurationValue.getTimeValue(targetEntity, applicationEntity, applicationType);
    duration.timeValue += storedValue;

    DurationValue.set(targetEntity, applicationEntity, applicationType, duration);

    return storedValue != 0;
  }

  /**
   * Remove duration for a specific key set
   */
  function remove(bytes32 targetEntity, bytes32 applicationEntity, bytes32 applicationType) internal {
    DurationValue.deleteRecord(targetEntity, applicationEntity, applicationType);
  }

  function decreaseApplications(bytes32 targetEntity, DurationValueData memory duration) internal {
    (bytes32[] memory applicationEntities, bytes32[] memory applicationTypes) = DurationIdxList.get(
      DurationValueTableId,
      targetEntity,
      duration.timeId
    );
    for (uint256 i; i < applicationEntities.length; i++) {
      bytes32 applicationEntity = applicationEntities[i];
      bytes32 applicationType = applicationTypes[i];

      uint256 storedValue = DurationValue.getTimeValue(targetEntity, applicationEntity, applicationType);

      if (storedValue > duration.timeValue) {
        DurationValueData memory decreasedDuration = DurationValueData({
          timeId: duration.timeId,
          timeValue: storedValue - duration.timeValue
        });
        DurationValue.set(targetEntity, applicationEntity, applicationType, decreasedDuration);
      } else {
        DurationValue.deleteRecord(targetEntity, applicationEntity, applicationType);
      }
    }
  }
}
