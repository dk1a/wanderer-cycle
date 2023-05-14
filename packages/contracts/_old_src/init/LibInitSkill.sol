// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibBaseInitSkill as b } from "./LibBaseInitSkill.sol";
import { SkillType, TargetType, SkillPrototype } from "../skill/SkillPrototypeComponent.sol";
import { Topics, Op, Element } from "../charstat/Topics.sol";
import { makeEffectPrototype, EffectRemovability } from "../effect/makeEffectPrototype.sol";

library LibInitSkill {
  function init(IWorld world) internal {
    b.Comps memory comps = b.getComps(world.components());

    // 1
    b.add(
      comps,
      "Cleave",
      "Attack with increased damage",
      SkillPrototype({
        requiredLevel: 1,
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: false,
        cost: 1,
        duration: b._duration("round", 1),
        cooldown: b._duration("round", 1),
        effectTarget: TargetType.SELF,
        spellDamage: b._emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.BUFF,
        Topics.ATTACK, Op.MUL, Element.ALL, 16,
        Topics.ATTACK, Op.ADD, Element.PHYSICAL, 2
      )
    );

    // 2
    b.add(
      comps,
      "Charge",
      "Greatly increase attack damage for the next combat round",
      SkillPrototype({
        requiredLevel: 2,
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 1,
        duration: b._duration("round_persistent", 1),
        cooldown: b._duration("turn", 3),
        effectTarget: TargetType.SELF,
        spellDamage: b._emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.BUFF,
        Topics.ATTACK, Op.MUL, Element.ALL, 64
      )
    );

    // 3
    b.add(
      comps,
      "Parry",
      "Increase physical resistance",
      SkillPrototype({
        requiredLevel: 3,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: b._noDuration(),
        cooldown: b._noDuration(),
        effectTarget: TargetType.SELF,
        spellDamage: b._emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.PERSISTENT,
        Topics.RESISTANCE, Op.ADD, Element.PHYSICAL, 8
      )
    );

    // 4
    b.add(
      comps,
      "Onslaught",
      "Increase attack damage and recover some life per round",
      SkillPrototype({
        requiredLevel: 4,
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 1,
        duration: b._duration("turn", 2),
        cooldown: b._duration("turn", 8),
        effectTarget: TargetType.SELF,
        spellDamage: b._emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.BUFF,
        Topics.ATTACK, Op.MUL, Element.ALL, 32,
        Topics.LIFE_GAINED_PER_TURN, Op.ADD, Element.ALL, 2
      )
    );

    // 5
    b.add(
      comps,
      "Toughness",
      "Increase life",
      SkillPrototype({
        requiredLevel: 5,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: b._noDuration(),
        cooldown: b._noDuration(),
        effectTarget: TargetType.SELF,
        spellDamage: b._emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.PERSISTENT,
        Topics.LIFE, Op.MUL, Element.ALL, 8
      )
    );

    // 6
    b.add(
      comps,
      "Thunder Clap",
      "Attack and deal physical spell damage",
      SkillPrototype({
        requiredLevel: 6,
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: true,
        cost: 4,
        duration: b._noDuration(),
        cooldown: b._duration("round", 4),
        effectTarget: TargetType.SELF,
        spellDamage: [uint32(0), 8, 0, 0, 0]
      }),
      makeEffectPrototype()
    );

    // 7
    b.add(
      comps,
      "Precise Strikes",
      "Increase attack damage",
      SkillPrototype({
        requiredLevel: 7,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: b._noDuration(),
        cooldown: b._noDuration(),
        effectTarget: TargetType.SELF,
        spellDamage: b._emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.PERSISTENT,
        Topics.ATTACK, Op.MUL, Element.ALL, 8
      )
    );

    // 8
    b.add(
      comps,
      "Blood Rage",
      "Gain an extra turn after a kill, once per day",
      SkillPrototype({
        requiredLevel: 8,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: b._noDuration(),
        // TODO this should have a day(?) cooldown somehow, maybe not here though
        cooldown: b._noDuration(),
        effectTarget: TargetType.SELF,
        spellDamage: b._emptyElemental()
      }),
      makeEffectPrototype()
    );

    // 9
    b.add(
      comps,
      "Retaliation",
      "Increases physical resistance\nIncreases physical attack damage proportional to missing life",
      SkillPrototype({
        requiredLevel: 9,
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: b._duration("turn", 1),
        cooldown: b._duration("turn", 16),
        effectTarget: TargetType.SELF,
        spellDamage: b._emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.BUFF,
        Topics.RESISTANCE, Op.ADD, Element.PHYSICAL, 8,
        Topics.PERCENT_OF_MISSING_LIFE_TO_ATTACK, Op.ADD, Element.PHYSICAL, 400
      )
    );

    // 10
    b.add(
      comps,
      "Last Stand",
      "Gain temporary life for 4 rounds",
      SkillPrototype({
        requiredLevel: 10,
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: false,
        cost: 1,
        duration: b._duration("round", 4),
        cooldown: b._duration("turn", 8),
        effectTarget: TargetType.SELF,
        spellDamage: b._emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.BUFF,
        Topics.LIFE, Op.MUL, Element.ALL, 32
        // TODO should this even be a modifier?
        //'recover #% of base life', 32
      )
    );

    // 11
    b.add(
      comps,
      "Weapon Mastery",
      // TODO this dual-wielding thing
      "Allows dual wielding one-handed weapons\nIncreases base attack",
      SkillPrototype({
        requiredLevel: 11,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: b._noDuration(),
        cooldown: b._noDuration(),
        effectTarget: TargetType.SELF,
        spellDamage: b._emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.PERSISTENT,
        Topics.ATTACK, Op.BADD, Element.PHYSICAL, 1
      )
    );
  }
}
