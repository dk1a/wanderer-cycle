// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { PackedCounter } from "@latticexyz/store/src/PackedCounter.sol";
import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { StoreHook } from "@latticexyz/store/src/StoreHook.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { DurationValue } from "../../codegen/tables/DurationValue.sol";
import { DurationIdxList } from "../../codegen/tables/DurationIdxList.sol";
import { DurationIdxMap } from "../../codegen/tables/DurationIdxMap.sol";

/**
 * An array of structs in DurationIdxList is simulated via 2 arrays of each element
 * So each List operation consists of 2 lines
 */
contract DurationIdxHook is StoreHook {
  function _decodeKeyTuple(
    bytes32[] memory keyTuple
  ) private pure returns (bytes32 targetEntity, bytes32 applicationEntity, bytes32 applicationType) {
    targetEntity = keyTuple[0];
    applicationEntity = keyTuple[1];
    applicationType = keyTuple[2];
  }

  /**
   * Adds the item to DurationIdxList and sets its index in DurationIdxMap
   */
  function _pushDurationIdx(
    ResourceId tableId,
    bytes32 targetEntity,
    bytes32 applicationEntity,
    bytes32 applicationType,
    bytes32 timeId
  ) private {
    // Each List array part should have the same length
    uint40 newIndex = uint40(DurationIdxList.lengthApplicationEntities(tableId, targetEntity, timeId));

    // Push to List
    DurationIdxList.pushApplicationEntities(tableId, targetEntity, timeId, applicationEntity);
    DurationIdxList.pushApplicationTypes(tableId, targetEntity, timeId, applicationType);

    // Update Map with the new index
    DurationIdxMap.set(tableId, targetEntity, applicationEntity, applicationType, true, newIndex);
  }

  /**
   * Removes the item from DurationIdxList and unsets its index in DurationIdxMap
   */
  function _swapAndPopDurationIdx(
    ResourceId tableId,
    bytes32 targetEntity,
    bytes32 applicationEntity,
    bytes32 applicationType,
    bytes32 timeId
  ) private {
    // Get the List index from Map
    (bool has, uint40 index) = DurationIdxMap.get(tableId, targetEntity, applicationEntity, applicationType);
    // Nothing to do if not in Map/List
    if (!has) return;

    // Each List array part should have the same length
    uint256 lastIndex = DurationIdxList.lengthApplicationEntities(tableId, targetEntity, timeId) - 1;

    // Get the last List struct
    bytes32 applicationEntityToSwap = DurationIdxList.getItemApplicationEntities(
      tableId,
      targetEntity,
      timeId,
      lastIndex
    );
    bytes32 applicationTypeToSwap = DurationIdxList.getItemApplicationTypes(tableId, targetEntity, timeId, lastIndex);

    // Swap the last List struct with the one at `index`
    DurationIdxList.updateApplicationEntities(tableId, targetEntity, timeId, index, applicationEntityToSwap);
    DurationIdxList.updateApplicationTypes(tableId, targetEntity, timeId, index, applicationTypeToSwap);

    // Pop the last List struct
    DurationIdxList.popApplicationEntities(tableId, targetEntity, timeId);
    DurationIdxList.popApplicationTypes(tableId, targetEntity, timeId);

    // Delete from Map
    DurationIdxMap.deleteRecord(tableId, targetEntity, applicationEntity, applicationType);
  }

  function handleSet(ResourceId tableId, bytes32[] memory keyTuple, bytes32 newTimeId) internal {
    (bytes32 targetEntity, bytes32 applicationEntity, bytes32 applicationType) = _decodeKeyTuple(keyTuple);

    bytes32 oldTimeId = DurationValue.getTimeId(targetEntity, applicationEntity, applicationType);

    if (oldTimeId != newTimeId) {
      _swapAndPopDurationIdx(tableId, targetEntity, applicationEntity, applicationType, oldTimeId);
    }

    bool has = DurationIdxMap.getHas(tableId, targetEntity, applicationEntity, applicationType);
    if (!has) {
      _pushDurationIdx(tableId, targetEntity, applicationEntity, applicationType, newTimeId);
    }
  }

  function onBeforeSetRecord(
    ResourceId tableId,
    bytes32[] memory keyTuple,
    bytes memory staticData,
    PackedCounter,
    bytes memory,
    FieldLayout
  ) public override {
    (bytes32 newTimeId, ) = DurationValue.decodeStatic(staticData);
    handleSet(tableId, keyTuple, newTimeId);
  }

  // TODO totally not supporting splice is easier, but setTimeValue can be useful for more efficient `decreaseApplications`
  /*function onAfterSpliceStaticData(
    ResourceId tableId,
    bytes32[] memory keyTuple,
    uint48 start,
    bytes memory staticData
  ) public override {
    if (start == 0 && staticData.length == 32) {
      bytes32 newTimeId = bytes32(staticData);
      handleSet(tableId, keyTuple, newTimeId);
    } else if (start < 32) {
      revert("partial timeId splice not supported");
    }
  }*/

  function onBeforeDeleteRecord(ResourceId tableId, bytes32[] memory keyTuple, FieldLayout) public override {
    (bytes32 targetEntity, bytes32 applicationEntity, bytes32 applicationType) = _decodeKeyTuple(keyTuple);

    bytes32 timeId = DurationValue.getTimeId(targetEntity, applicationEntity, applicationType);

    _swapAndPopDurationIdx(tableId, targetEntity, applicationEntity, applicationType, timeId);
  }
}
