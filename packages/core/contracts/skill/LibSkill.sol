// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { LearnedSkillsComponent, ID as LearnedSkillsComponentID } from "./LearnedSkillsComponent.sol";
import { LibLearnedSkills } from "./LibLearnedSkills.sol";
import { TBTime } from "../turn-based-time/TBTime.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibTimedEffect } from "../effect/LibTimedEffect.sol";
import {
  SkillType,
  TargetType,
  SkillPrototype,
  SkillPrototypeComponent,
  ID as SkillPrototypeComponentID
} from "./SkillPrototypeComponent.sol";

library LibSkill {
  using LibCharstat for LibCharstat.Self;
  using LibLearnedSkills for LibLearnedSkills.Self;
  using TBTime for TBTime.Self;
  using LibTimedEffect for LibTimedEffect.Self;

  error LibSkill__SkillMustBeLearned();
  error LibSkill__SkillOnCooldown();
  error LibSkill__NotEnoughMana();
  error LibSkill__InvalidSkillTarget();
  error LibSkill__RequiredCombat();
  error LibSkill__RequiredNonCombat();

  struct Self {
    IUint256Component registry;
    SkillPrototypeComponent protoComp;
    TBTime.Self tbtime;
    LibCharstat.Self charstat;
    LibLearnedSkills.Self learnedSkills;
    uint256 userEntity;

    uint256 skillEntity;
    SkillPrototype skill;
  }

  function __construct(
    IUint256Component registry,
    uint256 userEntity,
    uint256 skillEntity
  ) internal view returns (Self memory) {
    SkillPrototypeComponent protoComp = SkillPrototypeComponent(getAddressById(registry, SkillPrototypeComponentID));

    return Self({
      registry: registry,
      protoComp: protoComp,
      tbtime: TBTime.__construct(registry, userEntity),
      charstat: LibCharstat.__construct(registry, userEntity),
      learnedSkills: LibLearnedSkills.__construct(registry, userEntity),
      userEntity: userEntity,

      skillEntity: skillEntity,
      skill: protoComp.getValue(skillEntity)
    });
  }

  /**
   * @dev Change Self to use a different skill prototype
   */
  function switchSkill(
    Self memory __self,
    uint256 skillEntity
  ) internal view returns (Self memory) {
    __self.skillEntity = skillEntity;
    __self.skill = __self.protoComp.getValue(skillEntity);
    return __self;
  }

  function requireCombat(Self memory __self) internal pure {
    if (__self.skill.skillType != SkillType.COMBAT) {
      revert LibSkill__RequiredCombat();
    }
  }

  function requireNonCombat(Self memory __self) internal pure {
    if (__self.skill.skillType == SkillType.COMBAT) {
      revert LibSkill__RequiredNonCombat();
    }
  }

  /**
   * @dev Combat skills may target either self or enemy, depending on skill prototype
   */
  function chooseCombatTarget(
    Self memory __self,
    uint256 enemyEntity
  ) internal pure returns (uint256) {
    if (
      __self.skill.effectTarget == TargetType.SELF
      || __self.skill.effectTarget == TargetType.SELF_OR_ALLY
    ) {
      // self
      return __self.userEntity;
    } else if (__self.skill.effectTarget == TargetType.ENEMY) {
      // enemy
      return enemyEntity;
    } else {
      revert LibSkill__InvalidSkillTarget();
    }
  }

  /**
   * @dev Check some requirements, subtract cost, start cooldown, apply effect.
   * However this method is NOT combat aware and doesn't do attack/spell damage
   */
  function useSkill(
    Self memory __self,
    uint256 targetEntity
  ) internal {
    // must be learned
    if (!__self.learnedSkills.hasSkill(__self.skillEntity)) {
      revert LibSkill__SkillMustBeLearned();
    }
    // must be off cooldown
    if (__self.tbtime.has(__self.skillEntity)) {
      revert LibSkill__SkillOnCooldown();
    }
    // verify self-only skill
    if (__self.skill.effectTarget == TargetType.SELF && __self.userEntity != targetEntity) {
      revert LibSkill__InvalidSkillTarget();
    }
    // TODO verify other target types?

    // start cooldown
    __self.tbtime.increase(__self.skillEntity, __self.skill.cooldown);

    // check and subtract skill cost
    uint32 manaCurrent = __self.charstat.getManaCurrent();
    if (__self.skill.cost > manaCurrent) {
      revert LibSkill__NotEnoughMana();
    } else {
      __self.charstat.setManaCurrent(manaCurrent - __self.skill.cost);
    }

    _applySkillEffect(__self, targetEntity);
  }

  function _applySkillEffect(Self memory __self, uint256 targetEntity) private {
    LibTimedEffect.Self memory libTimedEffect = LibTimedEffect.__construct(__self.registry, targetEntity);

    if (!libTimedEffect.isEffectProto(__self.skillEntity)) {
      // skip if skill has no effect
      return;
    }

    if (__self.skill.skillType == SkillType.PASSIVE) {
      // toggle passive skill
      if (libTimedEffect.has(__self.skillEntity)) {
        libTimedEffect.remove(__self.skillEntity);
      } else {
        libTimedEffect.applyEffect(__self.skillEntity, __self.skill.duration);
      }
    } else {
      // apply active skill
      libTimedEffect.applyEffect(__self.skillEntity, __self.skill.duration);
    }
  }
}