// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library OffsetKeys {
    using OffsetKeys for Keys;

    struct Keys {
        uint64 _index;
        bytes4 _topic;
        uint64 _topicIndex;
    }

    function exists(
        Keys storage keys
    ) internal view returns (bool) {
        return keys._index != 0 && keys._topicIndex != 0;
    }

    modifier onlyIfExists(Keys storage keys) {
        require(keys.exists(), "OffsetKeys: nonexistent keys");
        _;
    }

    function getIndex(
        Keys storage keys
    ) internal view onlyIfExists(keys) returns (uint64) {
        return keys._index - 1;
    }

    function getTopicIndex(
        Keys storage keys
    ) internal view onlyIfExists(keys) returns (uint64) {
        return keys._topicIndex - 1;
    }

    function getTopic(
        Keys storage keys
    ) internal view onlyIfExists(keys) returns (bytes4) {
        return keys._topic;
    }

    function set(
        Keys storage keys,
        uint64 index,
        bytes4 topic,
        uint64 topicIndex
    ) internal {
        keys._index = index + 1;
        keys._topic = topic;
        keys._topicIndex = topicIndex + 1;
    }

    function swapIndex(
        Keys storage keysTo,
        Keys storage keysFrom
    ) internal onlyIfExists(keysFrom) {
        keysTo._index = keysFrom._index;
    }

    function swapTopicIndex(
        Keys storage keysTo,
        Keys storage keysFrom
    ) internal onlyIfExists(keysFrom) {
        keysTo._topicIndex = keysFrom._topicIndex;
    }
}