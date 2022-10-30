// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { EnumerableSet } from '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import { TimeManager, TimeStruct, TimeType, TimeStructIO } from '../time/TimeManager.sol';
import { TopicModifierMap, EffectModifier } from './TopicModifierMap.sol';
import { ModifierStorage, ModifierData } from '../../facets/modifier/ModifierStorage.sol';

enum EffectSource {
    SKILL,
    EQUIPMENT,
    MAP
}
enum EffectRemovability {
    BUFF,
    DEBUFF,
    PERSISTENT
}
struct EffectData {
    bytes32 sourceId;
    EffectSource source;
    EffectRemovability removability;
    bool withDuration;
    EffectModifier[] modifiers;
}
// see `values` function
struct EffectMapIO {
    TimeStructIO[] duration;
    bytes32[] effectIds;
    EffectData[] effectData;
}

struct EffectMap {
    // <effectId>TimedBytes32
    TimeManager.TimedBytes32 _duration;
    // <effectId>Bytes32Set
    EnumerableSet.Bytes32Set _effectIds;
    // effectId => EffectData
    mapping(bytes32 => EffectData) _effectData;

    TopicModifierMap.Map _topicModifiers;
}

/**
 * @title Manages active effects, aggregates their modifiers into TopicModifierMap
 * @dev effectId is hashed source,sourceId
 */
library EffectManager {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using TimeManager for TimeManager.TimedBytes32;
    using TopicModifierMap for TopicModifierMap.Map;
    using EffectManager for EffectMap;

    // ========== VIEW ==========

    /**
     * @dev returns whether the effectId (source, sourceId) exists
     */
    function exists(
        EffectMap storage map,
        EffectSource source,
        bytes32 sourceId
    ) internal view returns (bool) {
        bytes32 effectId = keccak256(abi.encodePacked(sourceId, source));
        return _exists(map, effectId);
    }

    function _exists(
        EffectMap storage map,
        bytes32 effectId
    ) private view returns (bool) {
        return map._effectIds.contains(effectId);
    }

    /**
     * @dev returns the aggregate of effects' modifiers for given topic
     */
    function getTopicModifiers(
        EffectMap storage map,
        bytes4 topic
    ) internal view returns (EffectModifier[] storage) {
        return map._topicModifiers.getTopic(topic);
    }

    /**
     * @dev returns everything for off-chain use
     * @dev (except topicModifiers, which are just aggregates of effects' modifiers)
     * @dev effectData doesn't have effectId, but shares indexes with effectIds
     * @dev duration has chaotic indexes, but does have effectId
     * @dev (also effects may not have a duration)
     */
    function values(
        EffectMap storage map
    ) internal view returns (EffectMapIO memory result) {
        result.duration = map._duration.values();
        result.effectIds = map._effectIds.values();

        uint256 length = result.effectIds.length;
        result.effectData = new EffectData[](length);
        for (uint256 i; i < length; i++) {
            bytes32 effectId = result.effectIds[i];
            result.effectData[i] = map._effectData[effectId];
        }
    }

    // ========== MODIFY ==========

    /**
     * @dev applies an effect, effectId is hashed source,sourceId
     * @dev repeated application increases duration
     * @dev except for consumables, which do their thing on-use, ignoring duration
     */
    function applyEffect(
        EffectMap storage map,
        EffectSource source,
        bytes32 sourceId,
        EffectRemovability removability,
        TimeStruct memory duration,
        // TODO figure out what to do if modifiers are empty
        EffectModifier[] memory modifiers
    ) internal {
        bytes32 effectId = keccak256(abi.encodePacked(sourceId, source));
        // INFINITY doesn't need to be tracked with TimeManager
        bool withDuration = duration.timeType != TimeType.INFINITY;

        // TODO what about if effect exists?? (extend buffs, replace whatever else?)
        bool effectExists = _exists(map, effectId);
        if (!effectExists) {
            // start duration
            if (withDuration) {
                map._duration.increase(effectId, duration);
            }

            // _exists will return true after effectId is added to set
            map._effectIds.add(effectId);
            // set effect data
            map._effectData[effectId].sourceId = sourceId;
            map._effectData[effectId].source = source;
            map._effectData[effectId].removability = removability;
            map._effectData[effectId].withDuration = withDuration;

            // add modifiers to this effect's modifiers list and to global TopicModifierMap
            // (TopicModifierMap is an aggregation of all effects' modifier values by modifier topic)
            for (uint256 i; i < modifiers.length; i++) {
                EffectModifier memory effectModifier = modifiers[i];
                ModifierData storage modifierData = ModifierStorage.modifierData(effectModifier.modifierId);
                bytes4 topic = modifierData.topic;
                    
                // the same modifier can be provided by several effects, with stacking values
                map._topicModifiers.increase(topic, effectModifier);
                // final modifier values are in topicModifiers,
                // but effects keep copies of their modifiers
                // to correctly decrease topicModifiers,
                // since effect's source can change values
                // (changes are used only after effect is removed and applied again)
                map._effectData[effectId].modifiers.push(effectModifier);
            }
        }
    }

    /**
     * @dev removes effectId, its modifiers and duration
     */
    function remove(
        EffectMap storage map,
        EffectSource source,
        bytes32 sourceId
    ) internal {
        bytes32 effectId = keccak256(abi.encodePacked(sourceId, source));
        if (map._effectData[effectId].withDuration) {
            map._duration.remove(effectId);
        }
        _remove(map, effectId);
    }

    /**
     * @dev removes effectId and its modifiers, assumes duration was already removed
     */
    function _remove(EffectMap storage map, bytes32 effectId) private {
        // remove effect from set
        map._effectIds.remove(effectId);
        // skip removing from _effectData mapping,
        // it will be overwritten by applyEffect when needed

        // subtract modifier values from _topicModifiers
        EffectModifier[] storage modifiers = map._effectData[effectId].modifiers;
        uint256 length = modifiers.length;
        for (uint256 i; i < length; i++) {
            // decrease will throw for absent modifiers, but that should be impossible
            map._topicModifiers.decrease(modifiers[i]);
        }
    }

    /**
     * @dev decreases duration for all effects and removes the ones that expire
     */
    function decreaseDuration(EffectMap storage map, TimeStruct memory time) internal {
        bytes32[] memory removedIds = map._duration.decrease(time);
        for (uint256 i; i < removedIds.length; i++) {
            _remove(map, removedIds[i]);
        }
    }
}