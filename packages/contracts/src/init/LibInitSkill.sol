// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { GenericDurationData, SkillTemplateData } from "../codegen/index.sol";
import { SkillType, TargetType, StatmodOp, EleStat } from "../codegen/common.sol";
import { LibBaseInitSkill as b } from "./LibBaseInitSkill.sol";
import { StatmodTopics } from "../modules/statmod/StatmodTopic.sol";
import { makeEffectTemplate } from "../modules/effect/makeEffectTemplate.sol";

library LibInitSkill {
  function init() internal {
    // 1
    b.add(
      "Cleave",
      "Attack with increased physical damage",
      SkillTemplateData({
        requiredLevel: 1,
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: false,
        cost: 1,
        targetType: TargetType.SELF
      }),
      // cooldown
      GenericDurationData("round", 1),
      // duration
      GenericDurationData("round", 1),
      // effect
      makeEffectTemplate(
        StatmodTopics.ATTACK,
        StatmodOp.MUL,
        EleStat.PHYSICAL,
        16,
        StatmodTopics.ATTACK,
        StatmodOp.ADD,
        EleStat.PHYSICAL,
        2
      )
    );

    // 2
    b.add(
      "Charge",
      "Greatly increase physical attack damage for the next combat round",
      SkillTemplateData({
        requiredLevel: 2,
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 1,
        targetType: TargetType.SELF
      }),
      // cooldown
      GenericDurationData("turn", 3),
      // duration
      GenericDurationData("round_persistent", 1),
      // effect
      makeEffectTemplate(StatmodTopics.ATTACK, StatmodOp.MUL, EleStat.PHYSICAL, 64)
    );

    // 3
    b.add(
      "Parry",
      "Increase physical resistance",
      SkillTemplateData({
        requiredLevel: 3,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        targetType: TargetType.SELF
      }),
      // cooldown
      b._noDuration(),
      // duration
      b._noDuration(),
      // effect
      makeEffectTemplate(StatmodTopics.RESISTANCE, StatmodOp.ADD, EleStat.PHYSICAL, 8)
    );
  }
}
