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

  error LibUseSkill__SkillMustBeLearned();
  error LibUseSkill__SkillOnCooldown();
  error LibUseSkill__NotEnoughMana();
  error LibUseSkill__InvalidSkillTarget();

  struct Self {
    IUint256Component registry;
    SkillPrototypeComponent protoComp;
    TBTime.Self tbtime;
    LibCharstat.Self charstat;
    LibLearnedSkills.Self learnedSkills;
    uint256 userEntity;
  }

  function __construct(
    IUint256Component registry,
    uint256 userEntity
  ) internal view returns (Self memory) {
    return Self({
      registry: registry,
      protoComp: SkillPrototypeComponent(getAddressById(registry, SkillPrototypeComponentID)),
      tbtime: TBTime.__construct(registry, userEntity),
      charstat: LibCharstat.__construct(registry, userEntity),
      learnedSkills: LibLearnedSkills.__construct(registry, userEntity),
      userEntity: userEntity
    });
  }

  /*
  function chooseTarget(
    uint256 sourceEntity,
    uint256 enemyEntity
  ) internal view returns (uint256) {
    TargetType effectTarget = SkillStorage.getEffectTarget(skillId);
    if (
      effectTarget == TargetType.SELF
      || effectTarget == TargetType.SELF_OR_ALLY
    ) {
      // self
      return instSource;
    } else if (effectTarget == TargetType.ENEMY) {
      // enemy
      return instEnemy;
    } else {
      revert SkillInvalidEffectTarget(skillId);
    }
  }
  */

  /**
   * @dev Check some requirements, subtract cost, start cooldown, apply effect.
   * However this method is NOT combat aware and doesn't do attack/spell damage
   * @return prototype skill prototype to do further checks/actions based on it
   */
  function applySkillEffect(
    Self memory __self,
    uint256 skillEntity,
    uint256 targetEntity
  ) internal returns (SkillPrototype memory prototype) {
    prototype = __self.protoComp.getValue(skillEntity);

    // must be learned
    if (!__self.learnedSkills.hasSkill(skillEntity)) {
      revert LibUseSkill__SkillMustBeLearned();
    }
    // must be off cooldown
    if (__self.tbtime.has(skillEntity)) {
      revert LibUseSkill__SkillOnCooldown();
    }
    // verify self-only skill
    if (prototype.effectTarget == TargetType.SELF && __self.userEntity != targetEntity) {
      revert LibUseSkill__InvalidSkillTarget();
    }
    // TODO verify other target types?

    // start cooldown
    __self.tbtime.increase(skillEntity, prototype.cooldown);

    // check and subtract skill cost
    uint32 manaCurrent = __self.charstat.getManaCurrent();
    if (prototype.cost > manaCurrent) {
      revert LibUseSkill__NotEnoughMana();
    } else {
      __self.charstat.setManaCurrent(manaCurrent - prototype.cost);
    }

    // init effect model and data
    LibEffect.Self memory libEffect = LibEffect.__construct(__self.registry, targetEntity);
    AppliedEffect memory appliedEffect = AppliedEffect({
      effectProtoEntity: skillEntity,
      source: bytes4(keccak256('skill')),
      removability: _getRemovability(prototype),
      statmods: prototype.statmods
    });

    if (prototype.skillType == SkillType.PASSIVE) {
      // toggle passive skill
      if (libEffect.has(skillEntity)) {
        libEffect.remove(skillEntity);
      } else {
        libEffect.applyEffect(appliedEffect, prototype.duration);
      }
    } else {
      // apply active skill
      libEffect.applyEffect(appliedEffect, prototype.duration);
    }
  }

  function _getRemovability(
    SkillPrototype memory skillPrototype
  ) private pure returns (EffectRemovability) {
    if (skillPrototype.skillType == SkillType.PASSIVE) {
      return EffectRemovability.PERSISTENT;
    } else if (skillPrototype.effectTarget == TargetType.ENEMY) {
      return EffectRemovability.DEBUFF;
    } else {
      return EffectRemovability.BUFF;
    }
  }
}