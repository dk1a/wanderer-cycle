// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { GenericDuration, GenericDurationData } from "./codegen/tables/GenericDuration.sol";
import { Idx_GenericDuration_TargetEntityTimeId } from "./codegen/idxs/Idx_GenericDuration_TargetEntityTimeId.sol";

library Duration {
  error Duration_IncreaseByZero();

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
    uint256 applicationEntitiesLength = Idx_GenericDuration_TargetEntityTimeId.length(
      tableId,
      targetEntity,
      duration.timeId
    );
    for (uint256 i; i < applicationEntitiesLength; i++) {
      bytes32 applicationEntity = Idx_GenericDuration_TargetEntityTimeId.get(tableId, targetEntity, duration.timeId, i);

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
  ) internal view returns (GenericDurationData memory) {
    return GenericDuration.get(tableId, targetEntity, applicationEntity);
  }

  function getTimeId(
    ResourceId tableId,
    bytes32 targetEntity,
    bytes32 applicationEntity
  ) internal view returns (bytes32) {
    return GenericDuration.getTimeId(tableId, targetEntity, applicationEntity);
  }

  function getTimeValue(
    ResourceId tableId,
    bytes32 targetEntity,
    bytes32 applicationEntity
  ) internal view returns (uint256) {
    return GenericDuration.getTimeValue(tableId, targetEntity, applicationEntity);
  }

  function has(ResourceId tableId, bytes32 targetEntity, bytes32 applicationEntity) internal view returns (bool) {
    (bool _has, ) = Idx_GenericDuration_TargetEntityTimeId.has(tableId, targetEntity, applicationEntity);
    return _has;
  }
}
