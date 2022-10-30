// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { EffectManager, EffectMap, EffectSource, EffectRemovability } from './EffectManager.sol';
import { TimeStruct, TimeType } from '../time/TimeManager.sol';
import { LootStorage } from '../../facets/loot/LootStorage.sol';

library EffectManagerEquipment {
    using EffectManager for EffectMap;

    function exists(
        EffectMap storage map,
        uint256 equipmentId
    ) internal view returns (bool) {
        return map.exists(EffectSource.EQUIPMENT, bytes32(equipmentId));
    }

    function applyEffect(
        EffectMap storage map,
        uint256 equipmentId
    ) internal {
        map.applyEffect(
            EffectSource.EQUIPMENT,
            bytes32(equipmentId),
            EffectRemovability.PERSISTENT,
            TimeStruct({
                timeType: TimeType.INFINITY,
                timeValue: 1
            }),
            LootStorage.getEffectModifiers(equipmentId)
        );
    }

    function removeEffect(
        EffectMap storage map,
        uint256 equipmentId
    ) internal {
        map.remove(
            EffectSource.EQUIPMENT,
            bytes32(equipmentId)
        );
    }
}