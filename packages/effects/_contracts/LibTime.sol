// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { TimeStruct, TimeType } from './TimeManager.sol';
import { CooldownStorage } from './CooldownStorage.sol';
import { TurnsStorage } from './TurnsStorage.sol';
import { InstanceId } from '../InstanceId.sol';
import { InstanceStorage } from '../InstanceStorage.sol';
import { EffectManager, EffectMap } from '../effect-manager/EffectManager.sol';

uint32 constant MAX_ROUNDS = 12;

/*
enum TimeType {
    TURN,
    ROUND,
    ROUND_PERSISTENT,
    DAY,
    INFINITY,
    _LAST
}
 */

library LibTime {
    using EffectManager for EffectMap;

    function passTime(InstanceId.Id instance, TimeStruct memory time) internal {
        InstanceStorage.effectMap(instance).decreaseDuration(time);

        if (InstanceId.getType(instance) == InstanceId.Type.WANDERER_CYCLE) {
            CooldownStorage.decreaseSkillCd(instance, time);
        }
    }

    /**
     * @dev Spends a turn, then passes time
     */
    function passTurn(InstanceId.Id instance) internal {
        if (InstanceId.getType(instance) == InstanceId.Type.WANDERER_CYCLE) {
            TurnsStorage.spendTurns(instance, 1);
        }

        passTime(instance, TimeStruct({
            timeType: TimeType.TURN,
            timeValue: 1
        }));
        passTime(instance, TimeStruct({
            timeType: TimeType.ROUND,
            timeValue: MAX_ROUNDS
        }));
    }

    function passRound(InstanceId.Id instance) internal {
        passTime(instance, TimeStruct({
            timeType: TimeType.ROUND,
            timeValue: 1
        }));
        passTime(instance, TimeStruct({
            timeType: TimeType.ROUND_PERSISTENT,
            timeValue: 1
        }));
    }

    // TODO this probably isn't the right way to do this?
    function passDay(InstanceId.Id instance) internal {
        passTime(instance, TimeStruct({
            timeType: TimeType.DAY,
            timeValue: 1
        }));
    }
}