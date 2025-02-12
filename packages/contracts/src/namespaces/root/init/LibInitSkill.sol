// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { GenericDurationData } from "../../duration/Duration.sol";
import { StatmodTopics } from "../../statmod/StatmodTopic.sol";
import { makeEffectTemplate } from "../../effect/makeEffectTemplate.sol";
import { SkillTemplateData } from "../codegen/index.sol";
import { SkillType, TargetType, StatmodOp, EleStat } from "../../../codegen/common.sol";
import { LibBaseInitSkill as b } from "./LibBaseInitSkill.sol";

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
      ),
      // spell damage
      b._emptyElemental()
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
      makeEffectTemplate(StatmodTopics.ATTACK, StatmodOp.MUL, EleStat.PHYSICAL, 64),
      // spell damage
      b._emptyElemental()
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
      makeEffectTemplate(StatmodTopics.RESISTANCE, StatmodOp.ADD, EleStat.PHYSICAL, 8),
      // spell damage
      b._emptyElemental()
    );

    // 4
    b.add(
      "Onslaught",
      "Increase physical attack damage and recover some life per round",
      SkillTemplateData({
        requiredLevel: 4,
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 1,
        targetType: TargetType.SELF
      }),
      // cooldown
      GenericDurationData("turn", 2),
      // duration
      GenericDurationData("round_persistent", 8),
      // effect
      makeEffectTemplate(
        StatmodTopics.ATTACK,
        StatmodOp.MUL,
        EleStat.PHYSICAL,
        32,
        StatmodTopics.LIFE_GAINED_PER_TURN,
        StatmodOp.ADD,
        EleStat.NONE,
        2
      ),
      // spell damage
      b._emptyElemental()
    );

    // 5
    b.add(
      "Toughness",
      "Increase life",
      SkillTemplateData({
        requiredLevel: 5,
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
      makeEffectTemplate(StatmodTopics.LIFE, StatmodOp.MUL, EleStat.NONE, 8),
      // spell damage
      b._emptyElemental()
    );

    // 6
    b.add(
      "Thunder Clap",
      "Attack and deal physical spell damage",
      SkillTemplateData({
        requiredLevel: 6,
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: true,
        cost: 4,
        targetType: TargetType.SELF
      }),
      // cooldown
      GenericDurationData("round", 4),
      // duration
      b._noDuration(),
      // effect
      makeEffectTemplate(),
      // spell damage
      [uint32(0), 8, 0, 0, 0]
    );

    // 7
    b.add(
      "Precise Strikes",
      "Increase physical attack damage",
      SkillTemplateData({
        requiredLevel: 7,
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
      makeEffectTemplate(StatmodTopics.ATTACK, StatmodOp.MUL, EleStat.PHYSICAL, 8),
      // spell damage
      b._emptyElemental()
    );

    // 8
    b.add(
      "Blood Rage",
      "Gain an extra turn after a kill, once per day",
      SkillTemplateData({
        requiredLevel: 8,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        targetType: TargetType.SELF
      }),
      // TODO this should have a day(?) cooldown somehow, maybe not here though
      // cooldown
      b._noDuration(),
      // duration
      b._noDuration(),
      // effect
      makeEffectTemplate(),
      // spell damage
      b._emptyElemental()
    );

    // 9
    b.add(
      "Retaliation",
      "Increases physical resistance\nIncreases physical attack damage proportional to missing life",
      SkillTemplateData({
        requiredLevel: 9,
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 0,
        targetType: TargetType.SELF
      }),
      // cooldown
      GenericDurationData("turn", 1),
      // duration
      GenericDurationData("turn", 16),
      // effect
      makeEffectTemplate(
        StatmodTopics.RESISTANCE,
        StatmodOp.ADD,
        EleStat.PHYSICAL,
        8,
        StatmodTopics.PERCENT_OF_MISSING_LIFE_TO_ATTACK,
        StatmodOp.ADD,
        EleStat.PHYSICAL,
        400
      ),
      // spell damage
      b._emptyElemental()
    );

    // 10
    b.add(
      "Last Stand",
      "Gain temporary life for 4 rounds",
      SkillTemplateData({
        requiredLevel: 10,
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: false,
        cost: 1,
        targetType: TargetType.SELF
      }),
      // cooldown
      GenericDurationData("round", 4),
      // duration
      GenericDurationData("turn", 8),
      // effect
      makeEffectTemplate(
        StatmodTopics.LIFE,
        StatmodOp.MUL,
        EleStat.NONE,
        32
        // TODO should this even be a modifier?
        //'recover #% of base life', 32
      ),
      // spell damage
      b._emptyElemental()
    );

    // 11
    b.add(
      "Weapon Mastery",
      // TODO this dual-wielding thing
      "Allows dual wielding one-handed weapons\nIncreases base attack",
      SkillTemplateData({
        requiredLevel: 11,
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
      makeEffectTemplate(StatmodTopics.ATTACK, StatmodOp.BADD, EleStat.PHYSICAL, 1),
      // spell damage
      b._emptyElemental()
    );
  }
}
