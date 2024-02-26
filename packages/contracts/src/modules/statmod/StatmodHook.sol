// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { PackedCounter } from "@latticexyz/store/src/PackedCounter.sol";
import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { StoreHook } from "@latticexyz/store/src/StoreHook.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { StatmodBase, StatmodIdxList, StatmodIdxMap } from "../../codegen/index.sol";
import { StatmodTopic } from "./StatmodTopic.sol";

error Statmod_NotInitialized(bytes32 baseEntity);

contract StatmodHook is StoreHook {
  function _decodeKeyTuple(bytes32[] memory keyTuple) private pure returns (bytes32 targetEntity, bytes32 baseEntity) {
    targetEntity = keyTuple[0];
    baseEntity = keyTuple[1];
  }

  /**
   * Adds the item to StatmodIdxList and sets its index in StatmodIdxMap
   */
  function _pushStatmodIdx(bytes32 targetEntity, bytes32 baseEntity, StatmodTopic statmodTopic) private {
    uint40 newIndex = uint40(StatmodIdxList.length(targetEntity, statmodTopic));

    // Push to List
    StatmodIdxList.push(targetEntity, statmodTopic, baseEntity);

    // Update Map with the new index
    StatmodIdxMap.set(targetEntity, baseEntity, statmodTopic, true, newIndex);
  }

  /**
   * Removes the item from DurationIdxList and unsets its index in DurationIdxMap
   */
  function _swapAndPopStatmodIdx(bytes32 targetEntity, bytes32 baseEntity) private {
    // Get the List index from Map
    (StatmodTopic statmodTopic, bool has, uint40 index) = StatmodIdxMap.get(targetEntity, baseEntity);
    // Nothing to do if not in Map/List
    if (!has) return;

    uint256 lastIndex = StatmodIdxList.length(targetEntity, statmodTopic) - 1;

    // Get the last List item
    bytes32 baseEntityToSwap = StatmodIdxList.getItem(targetEntity, statmodTopic, lastIndex);

    // Swap the last List item with the one at `index`
    StatmodIdxList.update(targetEntity, statmodTopic, index, baseEntityToSwap);
    // TODO is this line needed in DurationModule too?
    StatmodIdxMap.set(targetEntity, baseEntityToSwap, statmodTopic, true, index);

    // Pop the last List item
    StatmodIdxList.pop(targetEntity, statmodTopic);

    // Delete from Map
    StatmodIdxMap.deleteRecord(targetEntity, baseEntity);
  }

  function _getAndCheckStatmodTopic(bytes32 baseEntity) private view returns (StatmodTopic statmodTopic) {
    statmodTopic = StatmodBase.getStatmodTopic(baseEntity);
    if (StatmodTopic.unwrap(statmodTopic) == bytes32(0)) {
      revert Statmod_NotInitialized(baseEntity);
    }
  }

  function handleSet(bytes32[] memory keyTuple) internal {
    (bytes32 targetEntity, bytes32 baseEntity) = _decodeKeyTuple(keyTuple);

    StatmodTopic newStatmodTopic = _getAndCheckStatmodTopic(baseEntity);
    StatmodTopic oldStatmodTopic = StatmodIdxMap.getStatmodTopic(targetEntity, baseEntity);

    if (oldStatmodTopic != newStatmodTopic) {
      _swapAndPopStatmodIdx(targetEntity, baseEntity);
    }

    bool has = StatmodIdxMap.getHas(targetEntity, baseEntity);
    if (!has) {
      _pushStatmodIdx(targetEntity, baseEntity, newStatmodTopic);
    }
  }

  function onBeforeSetRecord(
    ResourceId,
    bytes32[] memory keyTuple,
    bytes memory,
    PackedCounter,
    bytes memory,
    FieldLayout
  ) public override {
    handleSet(keyTuple);
  }

  function onAfterSpliceStaticData(ResourceId, bytes32[] memory keyTuple, uint48, bytes memory) public override {
    handleSet(keyTuple);
  }

  function onBeforeDeleteRecord(ResourceId, bytes32[] memory keyTuple, FieldLayout) public override {
    (bytes32 targetEntity, bytes32 baseEntity) = _decodeKeyTuple(keyTuple);
    _swapAndPopStatmodIdx(targetEntity, baseEntity);
  }
}
