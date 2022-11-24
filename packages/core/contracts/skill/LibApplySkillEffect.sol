// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import { LearnedSkillsComponent, ID as LearnedSkillsComponentID } from "./LearnedSkillsComponent.sol";
import { LibLearnedSkills } from "./LibLearnedSkills.sol";
import { TBTime } from "../turn-based-time/TBTime.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibEffect, AppliedEffect, EffectRemovability } from "../effect/LibEffect.sol";
import {
  SkillType,
  TargetType,
  EffectStatmod,
  SkillPrototype,
  SkillPrototypeComponent,
  ID as SkillPrototypeComponentID
} from "./SkillPrototypeComponent.sol";

library LibApplySkillEffect {
  using LibCharstat for LibCharstat.Self;
  using LibLearnedSkills for LibLearnedSkills.Self;
  using TBTime for TBTime.Self;
  using LibEffect for LibEffect.Self;

  error LibApplySkillEffect__SkillMustBeLearned();
  error LibApplySkillEffect__SkillOnCooldown();
  error LibApplySkillEffect__NotEnoughMana();
  error LibApplySkillEffect__InvalidSkillTarget();
  error LibApplySkillEffect__RequiredCombat();
  error LibApplySkillEffect__RequiredNonCombat();

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
      revert LibApplySkillEffect__RequiredCombat();
    }
  }

  function requireNonCombat(Self memory __self) internal pure {
    if (__self.skill.skillType == SkillType.COMBAT) {
      revert LibApplySkillEffect__RequiredNonCombat();
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
      revert LibApplySkillEffect__InvalidSkillTarget();
    }
  }

  /**
   * @dev Check some requirements, subtract cost, start cooldown, apply effect.
   * However this method is NOT combat aware and doesn't do attack/spell damage
   */
  function applySkillEffect(
    Self memory __self,
    uint256 targetEntity
  ) internal {
    // must be learned
    if (!__self.learnedSkills.hasSkill(__self.skillEntity)) {
      revert LibApplySkillEffect__SkillMustBeLearned();
    }
    // must be off cooldown
    if (__self.tbtime.has(__self.skillEntity)) {
      revert LibApplySkillEffect__SkillOnCooldown();
    }
    // verify self-only skill
    if (__self.skill.effectTarget == TargetType.SELF && __self.userEntity != targetEntity) {
      revert LibApplySkillEffect__InvalidSkillTarget();
    }
    // TODO verify other target types?

    // start cooldown
    __self.tbtime.increase(__self.skillEntity, __self.skill.cooldown);

    // check and subtract skill cost
    uint32 manaCurrent = __self.charstat.getManaCurrent();
    if (__self.skill.cost > manaCurrent) {
      revert LibApplySkillEffect__NotEnoughMana();
    } else {
      __self.charstat.setManaCurrent(manaCurrent - __self.skill.cost);
    }

    // init effect model and data
    LibEffect.Self memory libEffect = LibEffect.__construct(__self.registry, targetEntity);
    AppliedEffect memory appliedEffect = AppliedEffect({
      effectProtoEntity: __self.skillEntity,
      source: bytes4(keccak256('skill')),
      removability: _getRemovability(__self),
      statmods: __self.skill.statmods
    });

    if (__self.skill.skillType == SkillType.PASSIVE) {
      // toggle passive skill
      if (libEffect.has(__self.skillEntity)) {
        libEffect.remove(__self.skillEntity);
      } else {
        libEffect.applyEffect(appliedEffect, __self.skill.duration);
      }
    } else {
      // apply active skill
      libEffect.applyEffect(appliedEffect, __self.skill.duration);
    }
  }

  function _getRemovability(
    Self memory __self
  ) private pure returns (EffectRemovability) {
    if (__self.skill.skillType == SkillType.PASSIVE) {
      return EffectRemovability.PERSISTENT;
    } else if (__self.skill.effectTarget == TargetType.ENEMY) {
      return EffectRemovability.DEBUFF;
    } else {
      return EffectRemovability.BUFF;
    }
  }
}