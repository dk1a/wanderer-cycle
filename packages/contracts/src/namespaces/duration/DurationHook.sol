// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { EncodedLengths } from "@latticexyz/store/src/EncodedLengths.sol";
import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { StoreHook } from "@latticexyz/store/src/StoreHook.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { GenericDuration, DurationIdxList, DurationIdxMap } from "./codegen/index.sol";

contract DurationHook is StoreHook {
  function _decodeKeyTuple(
    bytes32[] memory keyTuple
  ) private pure returns (bytes32 targetEntity, bytes32 applicationEntity) {
    targetEntity = keyTuple[0];
    applicationEntity = keyTuple[1];
  }

  /**
   * Adds the item to DurationIdxList and sets its index in DurationIdxMap
   */
  function _pushDurationIdx(
    ResourceId tableId,
    bytes32 targetEntity,
    bytes32 applicationEntity,
    bytes32 timeId
  ) private {
    uint40 newIndex = uint40(DurationIdxList.lengthApplicationEntities(tableId, targetEntity, timeId));

    // Push to List
    DurationIdxList.pushApplicationEntities(tableId, targetEntity, timeId, applicationEntity);

    // Update Map with the new index
    DurationIdxMap.set(tableId, targetEntity, applicationEntity, true, newIndex);
  }

  /**
   * Removes the item from DurationIdxList and unsets its index in DurationIdxMap
   */
  function _swapAndPopDurationIdx(
    ResourceId tableId,
    bytes32 targetEntity,
    bytes32 applicationEntity,
    bytes32 timeId
  ) private {
    // Get the List index from Map
    (bool has, uint40 index) = DurationIdxMap.get(tableId, targetEntity, applicationEntity);
    // Nothing to do if not in Map/List
    if (!has) return;

    // Each List array part should have the same length
    uint256 lastIndex = DurationIdxList.lengthApplicationEntities(tableId, targetEntity, timeId) - 1;

    // Get the last List item
    bytes32 applicationEntityToSwap = DurationIdxList.getItemApplicationEntities(
      tableId,
      targetEntity,
      timeId,
      lastIndex
    );

    // Swap the last List item with the one at `index`
    DurationIdxList.updateApplicationEntities(tableId, targetEntity, timeId, index, applicationEntityToSwap);

    // Pop the last List item
    DurationIdxList.popApplicationEntities(tableId, targetEntity, timeId);

    // Delete from Map
    DurationIdxMap.deleteRecord(tableId, targetEntity, applicationEntity);
  }

  function handleSet(ResourceId tableId, bytes32[] memory keyTuple, bytes32 newTimeId) internal {
    (bytes32 targetEntity, bytes32 applicationEntity) = _decodeKeyTuple(keyTuple);

    bytes32 oldTimeId = GenericDuration.getTimeId(tableId, targetEntity, applicationEntity);

    if (oldTimeId != newTimeId) {
      _swapAndPopDurationIdx(tableId, targetEntity, applicationEntity, oldTimeId);
    }

    bool has = DurationIdxMap.getHas(tableId, targetEntity, applicationEntity);
    if (!has) {
      _pushDurationIdx(tableId, targetEntity, applicationEntity, newTimeId);
    }
  }

  function onBeforeSetRecord(
    ResourceId tableId,
    bytes32[] memory keyTuple,
    bytes memory staticData,
    EncodedLengths,
    bytes memory,
    FieldLayout
  ) public override {
    (bytes32 newTimeId, ) = GenericDuration.decodeStatic(staticData);
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
    (bytes32 targetEntity, bytes32 applicationEntity) = _decodeKeyTuple(keyTuple);

    bytes32 timeId = GenericDuration.getTimeId(tableId, targetEntity, applicationEntity);

    _swapAndPopDurationIdx(tableId, targetEntity, applicationEntity, timeId);
  }
}
