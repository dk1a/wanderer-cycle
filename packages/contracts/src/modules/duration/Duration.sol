// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { GenericDuration, GenericDurationData, DurationIdxList, DurationIdxMap } from "../../codegen/index.sol";

library Duration {
  error Duration_IncreaseByZero();
  error Duration_EntityAbsent();

  /**
   * Increase duration for a specific key set
   * @return isUpdate true if an existing value was increased; false if a new value was set
   */
  function increase(
    ResourceId tableId,
    bytes32 targetEntity,
    bytes32 applicationEntity,
    GenericDurationData memory duration
  ) internal returns (bool isUpdate) {
    if (duration.timeValue == 0) {
      revert Duration_IncreaseByZero();
    }

    uint256 storedValue = GenericDuration.getTimeValue(tableId, targetEntity, applicationEntity);
    duration.timeValue += storedValue;

    GenericDuration.set(tableId, targetEntity, applicationEntity, duration);

    return storedValue != 0;
  }

  /**
   * Remove duration for a specific key set
   */
  function remove(ResourceId tableId, bytes32 targetEntity, bytes32 applicationEntity) internal {
    GenericDuration.deleteRecord(tableId, targetEntity, applicationEntity);
  }

  function decreaseApplications(
    ResourceId tableId,
    bytes32 targetEntity,
    GenericDurationData memory duration
  ) internal {
    bytes32[] memory applicationEntities = DurationIdxList.get(tableId, targetEntity, duration.timeId);
    for (uint256 i; i < applicationEntities.length; i++) {
      bytes32 applicationEntity = applicationEntities[i];

      uint256 storedValue = GenericDuration.getTimeValue(tableId, targetEntity, applicationEntity);

      if (storedValue > duration.timeValue) {
        GenericDurationData memory decreasedDuration = GenericDurationData({
          timeId: duration.timeId,
          timeValue: storedValue - duration.timeValue
        });
        GenericDuration.set(tableId, targetEntity, applicationEntity, decreasedDuration);
      } else {
        GenericDuration.deleteRecord(tableId, targetEntity, applicationEntity);
      }
    }
  }

  function get(
    ResourceId tableId,
    bytes32 targetEntity,
    bytes32 applicationEntity
  ) internal returns (GenericDurationData memory) {
    return GenericDuration.get(tableId, targetEntity, applicationEntity);
  }

  function getTimeId(ResourceId tableId, bytes32 targetEntity, bytes32 applicationEntity) internal returns (bytes32) {
    return GenericDuration.getTimeId(tableId, targetEntity, applicationEntity);
  }

  function getTimeValue(
    ResourceId tableId,
    bytes32 targetEntity,
    bytes32 applicationEntity
  ) internal returns (uint256) {
    return GenericDuration.getTimeValue(tableId, targetEntity, applicationEntity);
  }

  function has(ResourceId tableId, bytes32 targetEntity, bytes32 applicationEntity) internal returns (bool) {
    return DurationIdxMap.getHas(tableId, targetEntity, applicationEntity);
  }
}
