// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { EffectManager, EffectMap, EffectSource } from './EffectManager.sol';
import { SkillStorage } from '../../facets/skill/SkillStorage.sol';

library EffectManagerSkill {
    using EffectManager for EffectMap;

    function exists(
        EffectMap storage map,
        bytes4 skillId
    ) internal view returns (bool) {
        return map.exists(EffectSource.SKILL, bytes32(skillId));
    }

    function applyEffect(
        EffectMap storage map,
        bytes4 skillId
    ) internal {
        map.applyEffect(
            EffectSource.SKILL,
            bytes32(skillId),
            SkillStorage.getRemovability(skillId),
            SkillStorage.getDuration(skillId),
            SkillStorage.getModifiers(skillId)
        );
    }

    function removeEffect(
        EffectMap storage map,
        bytes4 skillId
    ) internal {
        map.remove(
            EffectSource.SKILL,
            bytes32(skillId)
        );
    }
}