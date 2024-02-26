// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibLearnedSkills } from "./LibLearnedSkills.sol";
import { SkillTemplate, SkillTemplateData, SkillCooldownTableId, LearnedSkills, EffectDuration, EffectTemplate, ManaCurrent, LifeCurrent, GenericDurationData } from "../codegen/index.sol";
import { LibEffect } from "../modules/effect/LibEffect.sol";
import { SkillType, TargetType } from "../codegen/common.sol";
import { LibEffectPrototype } from "../effect/LibEffectPrototype.sol";
import { Duration } from "../modules/duration/Duration.sol";

library LibSkill {
  error LibSkill_SkillMustBeLearned();
  error LibSkill_SkillOnCooldown();
  error LibSkill_NotEnoughMana();
  error LibSkill_InvalidSkillTarget();
  error LibSkill_RequiredCombat();
  error LibSkill_RequiredNonCombat();

  function requireCombat(bytes32 skillEntity) internal view {
    if (SkillTemplate.getSkillType(skillEntity) != SkillType.COMBAT) {
      revert LibSkill_RequiredCombat();
    }
  }

  function requireNonCombat(bytes32 skillEntity) internal view {
    if (SkillTemplate.getSkillType(skillEntity) == SkillType.COMBAT) {
      revert LibSkill_RequiredNonCombat();
    }
  }

  /**
   * @dev Combat skills may target either self or enemy, depending on skill template
   */
  function chooseCombatTarget(
    bytes32 userEntity,
    bytes32 skillEntity,
    bytes32 enemyEntity
  ) internal view returns (bytes32) {
    TargetType targetType = SkillTemplate.getTargetType(skillEntity);
    if (targetType == TargetType.SELF || targetType == TargetType.SELF_OR_ALLY) {
      // Self
      return userEntity;
    } else if (targetType == TargetType.ENEMY) {
      // Enemy
      return enemyEntity;
    } else {
      revert LibSkill_InvalidSkillTarget();
    }
  }

  /**
   * @dev Check some requirements, subtract cost, start cooldown, apply effect.
   * However this method is NOT combat aware and doesn't do attack/spell damage
   */
  function useSkill(bytes32 userEntity, bytes32 skillEntity, bytes32 targetEntity) internal {
    SkillTemplateData memory skill = SkillTemplate.get(skillEntity);

    // Must be learned
    if (!LibLearnedSkills.hasSkill(userEntity, skillEntity)) {
      revert LibSkill_SkillMustBeLearned();
    }
    // Must be off cooldown
    if (Duration.has(SkillCooldownTableId, targetEntity, skillEntity)) {
      revert LibSkill_SkillOnCooldown();
    }
    // Verify self-only skill
    if (skill.targetType == TargetType.SELF && userEntity != targetEntity) {
      revert LibSkill_InvalidSkillTarget();
    }
    // TODO verify other target types?

    // Start cooldown
    if (Duration.getTimeValue(SkillCooldownTableId, targetEntity, skillEntity) > 0) {
      Duration.increase(
        SkillCooldownTableId,
        targetEntity,
        skillEntity,
        GenericDurationData({ timeId: skill.cooldownTimeId, timeValue: skill.cooldownTimeValue })
      );
    }

    // Check and subtract skill cost
    uint32 manaCurrent = LibCharstat.getManaCurrent(targetEntity);
    if (skill.cost > manaCurrent) {
      revert LibSkill_NotEnoughMana();
    } else if (skill.cost > 0) {
      LibCharstat.setManaCurrent(skillEntity, manaCurrent - skill.cost);
    }

    _applySkillEffect(skillEntity, skill, targetEntity);
  }

  function _applySkillEffect(bytes32 skillEntity, SkillTemplateData memory skill, bytes32 targetEntity) private {
    if (!LibEffect.hasEffectTemplate(skillEntity)) {
      // skip if skill has no effect
      return;
    }

    if (skill.skillType == SkillType.PASSIVE) {
      // toggle passive skill
      if (LibEffect.hasEffectApplied(targetEntity, skillEntity)) {
        LibEffect.remove(targetEntity, skillEntity);
      } else {
        LibEffect.applyEffect(targetEntity, skillEntity);
      }
    } else {
      // apply active skill
      GenericDurationData memory duration = GenericDurationData({
        timeId: skill.durationTimeId,
        timeValue: skill.durationTimeValue
      });
      LibEffect.applyTimedEffect(targetEntity, skillEntity, duration);
    }
  }
}
