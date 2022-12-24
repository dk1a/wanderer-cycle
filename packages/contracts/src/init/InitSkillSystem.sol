// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { BaseInitSkillSystem } from "./BaseInitSkillSystem.sol";
import { SkillType, TargetType, SkillPrototype } from "../skill/SkillPrototypeComponent.sol";
import { Topics, Op, Element } from "../charstat/Topics.sol";
import { makeEffectPrototype, EffectRemovability } from "../effect/makeEffectPrototype.sol";

uint256 constant ID = uint256(keccak256("system.InitSkill"));

contract InitSkillSystem is BaseInitSkillSystem {
  constructor(IWorld _world, address _components) BaseInitSkillSystem(_world, _components) {}

  function execute(bytes memory) public override onlyOwner returns (bytes memory) {
    // 1
    add(
      'Cleave',
      'Attack with increased damage',
      SkillPrototype({
        requiredLevel: 1,
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: false,
        cost: 1,
        duration: _duration('round', 1),
        cooldown: _duration('round', 1),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.BUFF,
        Topics.ATTACK, Op.MUL, Element.ALL, 16,
        Topics.ATTACK, Op.ADD, Element.PHYSICAL, 2
      )
    );

    // 2 
    add(
      'Charge',
      'Greatly increase attack damage for the next combat round',
      SkillPrototype({
        requiredLevel: 2,
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 1,
        duration: _duration('round_persistent', 1),
        cooldown: _duration('turn', 3),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.BUFF,
        Topics.ATTACK, Op.MUL, Element.ALL, 64
      )
    );

    // 3
    add(
      'Parry',
      'Increase physical resistance',
      SkillPrototype({
        requiredLevel: 3,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noDuration(),
        cooldown: _noDuration(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.PERSISTENT,
        Topics.RESISTANCE, Op.ADD, Element.PHYSICAL, 8
      )
    );

    // 4
    add(
      'Onslaught',
      'Increase attack damage and recover some life per round',
      SkillPrototype({
        requiredLevel: 4,
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 1,
        duration: _duration('turn', 2),
        cooldown: _duration('turn', 8),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.BUFF,
        Topics.ATTACK, Op.MUL, Element.ALL, 32,
        Topics.LIFE_GAINED_PER_TURN, Op.ADD, Element.ALL, 2
      )
    );

    // 5
    add(
      'Toughness',
      'Increase life',
      SkillPrototype({
        requiredLevel: 5,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noDuration(),
        cooldown: _noDuration(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.PERSISTENT,
        Topics.LIFE, Op.MUL, Element.ALL, 8
      )
    );

    // 6
    add(
      'Thunder Clap',
      'Attack and deal physical spell damage',
      SkillPrototype({
        requiredLevel: 6,
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: true,
        cost: 4,
        duration: _noDuration(),
        cooldown: _duration("round", 4),
        effectTarget: TargetType.SELF,
        spellDamage: [uint32(0), 8, 0, 0, 0]
      }),
      makeEffectPrototype()
    );

    // 7
    add(
      'Precise Strikes',
      'Increase attack damage',
      SkillPrototype({
        requiredLevel: 7,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noDuration(),
        cooldown: _noDuration(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.PERSISTENT,
        Topics.ATTACK, Op.MUL, Element.ALL, 8
      )
    );

    // 8
    add(
      'Blood Rage',
      'Gain an extra turn after a kill, once per day',
      SkillPrototype({
        requiredLevel: 8,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noDuration(),
        // TODO this should have a day(?) cooldown somehow, maybe not here though
        cooldown: _noDuration(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      makeEffectPrototype()
    );

    // 9
    add(
      'Retaliation',
      'Increases physical resistance\nIncreases physical attack damage proportional to missing life',
      SkillPrototype({
        requiredLevel: 9,
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _duration('turn', 1),
        cooldown: _duration('turn', 16),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.BUFF,
        Topics.RESISTANCE, Op.ADD, Element.PHYSICAL, 8,
        Topics.PERCENT_OF_MISSING_LIFE_TO_ATTACK, Op.ADD, Element.PHYSICAL, 400
      )
    );

    // 10
    add(
      'Last Stand',
      'Gain temporary life for 4 rounds',
      SkillPrototype({
        requiredLevel: 10,
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: false,
        cost: 1,
        duration: _duration('round', 4),
        cooldown: _duration('turn', 8),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.BUFF,
        Topics.LIFE, Op.MUL, Element.ALL, 32
        // TODO should this even be a modifier?
        //'recover #% of base life', 32
      )
    );

    // 11
    add(
      'Weapon Mastery',
      // TODO this dual-wielding thing
      'Allows dual wielding one-handed weapons\nIncreases base attack',
      SkillPrototype({
        requiredLevel: 11,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noDuration(),
        cooldown: _noDuration(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      makeEffectPrototype(
        EffectRemovability.PERSISTENT,
        Topics.ATTACK, Op.BADD, Element.PHYSICAL, 1
      )
    );

    return '';
  }
}