// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { OffsetKeys } from './OffsetKeys.sol';

struct EffectModifier {
    bytes4 modifierId;
    uint32 modifierValue;
}

/**
 * @dev Enumerable map for EffectModifier, which also allows getting slices by topic
 * @dev and has increase(sets if 0)/decrease(removes if 0) helper methods for modifierValue
 * @dev Based on EnumerableMap from https://github.com/solidstate-network/solidstate-solidity/
 * 
 * The idea with this map is that eventually there will be many not-often-updated
 * entries, which are often-read, and usually need to be filtered by a topic;
 * so in addition to being a ModifierMap, it also optimizes for reading entries by topic.
 *
 * TODO I'm not sure this is a good idea though,
 * maybe just looping an EnumerableMap would be better.
 */
library TopicModifierMap {
    using OffsetKeys for OffsetKeys.Keys;
    using TopicModifierMap for Map;

    struct Map {
        // index => { modifierId, modifierValue }
        EffectModifier[] _entries;
        // modifierId => { index, topic, topicIndex }
        mapping(bytes4 => OffsetKeys.Keys) _keys;
        // topic => [{ modifierId, modifierValue }]
        mapping(bytes4 => EffectModifier[]) _topicEntries;
    }

    function at(
        Map storage map,
        uint256 index
    ) internal view returns (EffectModifier memory) {
        return map._entries[index];
    }

    function contains(
        Map storage map,
        bytes4 id
    ) internal view returns (bool) {
        return map._keys[id].exists();
    }

    /**
     * @dev get 1 entry by id
     */
    function get(
        Map storage map,
        bytes4 id
    ) internal view returns (EffectModifier memory) {
        uint256 index = map._keys[id].getIndex();
        return map._entries[index];
    }

    /**
     * @dev get all entries for given topic
     */
    function getTopic(
        Map storage map,
        bytes4 topic
    ) internal view returns (EffectModifier[] storage) {
        return map._topicEntries[topic];
    }

    /**
     * @dev set entry and its topic
     * @dev updating an entry's topic via this method is allowed
     */
    function set(
        Map storage map,
        bytes4 topic,
        EffectModifier memory entry
    ) internal {
        if (map.contains(entry.modifierId)) {
            _updateWithTopic(map, topic, entry);
        } else {
            _create(map, topic, entry);
        }
    }

    /**
     * @dev create new entry
     * @dev does not check for duplicates, check them before calling this!
     */
    function _create(
        Map storage map,
        bytes4 topic,
        EffectModifier memory entry
    ) private {
        require(
            entry.modifierValue > 0,
            'TopicModifierMap: invalid modifierValue'
        );
        uint256 len = map._entries.length;
        uint256 topicLen = map._topicEntries[topic].length;
        map._entries.push(entry);
        map._topicEntries[topic].push(entry);
        map._keys[entry.modifierId].set(uint64(len), topic, uint64(topicLen));
        assert(len <= type(uint64).max && topicLen <= type(uint64).max);
    }

    /**
     * @dev update existing entry
     */
    function _update(
        Map storage map,
        EffectModifier memory entry
    ) private {
        (OffsetKeys.Keys storage keys, ) = _partialUpdate(map, entry);
        map._topicEntries[keys.getTopic()][keys.getTopicIndex()] = entry;
    }

    /**
     * @dev update existing entry and change its topic if needed
     */
    function _updateWithTopic(
        Map storage map,
        bytes4 topic,
        EffectModifier memory entry
    ) private {
        (OffsetKeys.Keys storage keys, uint64 index) = _partialUpdate(map, entry);
        // topic could change for existing entries, but normally shouldn't
        if (keys.getTopic() == topic) {
            map._topicEntries[topic][keys.getTopicIndex()] = entry;
        } else {
            // remove from old topic
            _removeTopicEntry(map, keys);
            // add to new topic
            uint256 topicLen = map._topicEntries[topic].length;
            map._topicEntries[topic].push(entry);
            keys.set(index, topic, uint64(topicLen));
            assert(topicLen <= type(uint64).max);
        }
    }

    /**
     * @dev non-topic-related code used in both _update and _updateWithTopic
     */
    function _partialUpdate(
        Map storage map,
        EffectModifier memory entry
    ) private returns (OffsetKeys.Keys storage keys, uint64 index) {
        require(
            entry.modifierValue > 0,
            'TopicModifierMap: invalid modifierValue'
        );
        keys = map._keys[entry.modifierId];
        index = keys.getIndex();

        map._entries[index] = entry;
    }

    /**
     * @dev increases existing value by given value
     * @dev sets value for nonexistent entries
     */
    function increase(
        Map storage map,
        bytes4 topic,
        EffectModifier memory entry
    ) internal {
        if (map.contains(entry.modifierId)) {
            // create new object to avoid side effects for caller
            _updateWithTopic(map, topic, EffectModifier({
                modifierId: entry.modifierId,
                modifierValue: map.get(entry.modifierId).modifierValue + entry.modifierValue
            }));
        } else {
            _create(map, topic, entry);
        }
    }

    /**
     * @dev returns length of all entries
     */
    function length(Map storage map) internal view returns (uint256) {
        return map._entries.length;
    }

    /**
     * @dev remove given id
     * @dev throws for nonexistent
     */
    function remove(Map storage map, bytes4 id) internal {
        // TODO check existence and do nothing instead of throw??
        OffsetKeys.Keys storage keys = map._keys[id];

        // swap and pop
        EffectModifier memory last = map._entries[map._entries.length - 1];
        map._entries[keys.getIndex()] = last;
        map._keys[last.modifierId].swapIndex(keys);
        map._entries.pop();
        
        _removeTopicEntry(map, keys);

        delete map._keys[id];
    }

    function _removeTopicEntry(Map storage map, OffsetKeys.Keys storage keys) private {
        // swap and pop topicEntries
        EffectModifier[] storage topicEntries = map._topicEntries[keys.getTopic()];
        EffectModifier memory topicLast = topicEntries[topicEntries.length - 1];
        
        topicEntries[keys.getTopicIndex()] = topicLast;
        map._keys[topicLast.modifierId].swapTopicIndex(keys);
        topicEntries.pop();
    }

    /**
     * @dev decreases existing value by given value
     * @dev removes entry instead if value would become <= 0
     * @dev throws for nonexistent entries
     */
    function decrease(Map storage map, EffectModifier memory entry) internal {
        uint32 curModifierValue = map.get(entry.modifierId).modifierValue;
        if (curModifierValue > entry.modifierValue) {
            // create new object to avoid side effects for caller
            _update(map, EffectModifier({
                modifierId: entry.modifierId,
                modifierValue: curModifierValue - entry.modifierValue
            }));
        } else {
            remove(map, entry.modifierId);
        }
    }
}