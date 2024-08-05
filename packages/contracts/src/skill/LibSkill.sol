// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibLearnedSkills } from "./LibLearnedSkills.sol";
import { SkillTemplate, SkillTemplateData, SkillTemplateCooldown, SkillTemplateCooldownData, SkillTemplateDuration, SkillTemplateDurationData, SkillCooldown, SkillNameToEntity, LearnedSkills, EffectDuration, EffectTemplate, ManaCurrent, LifeCurrent, GenericDurationData } from "../codegen/index.sol";
import { LibEffect } from "../modules/effect/LibEffect.sol";
import { SkillType, TargetType } from "../codegen/common.sol";
import { Duration } from "../modules/duration/Duration.sol";

library LibSkill {
  error LibSkill_InvalidSkill();
  error LibSkill_SkillMustBeLearned();
  error LibSkill_SkillOnCooldown();
  error LibSkill_NotEnoughMana();
  error LibSkill_InvalidSkillTarget();
  error LibSkill_RequiredCombat();
  error LibSkill_RequiredNonCombat();

  function getSkillEntity(string memory name) internal view returns (bytes32 skillEntity) {
    skillEntity = SkillNameToEntity.get(keccak256(bytes(name)));
    if (skillEntity == bytes32(0)) {
      revert LibSkill_InvalidSkill();
    }
  }

  function getSkillTemplateCooldown(bytes32 skillEntity) internal view returns (GenericDurationData memory result) {
    SkillTemplateCooldownData memory uncastResult = SkillTemplateCooldown.get(skillEntity);
    assembly {
      result := uncastResult
    }
  }

  function setSkillTemplateCooldown(bytes32 skillEntity, GenericDurationData memory uncastData) internal {
    SkillTemplateCooldownData memory data;
    assembly {
      data := uncastData
    }
    SkillTemplateCooldown.set(skillEntity, data);
  }

  function getSkillTemplateDuration(bytes32 skillEntity) internal view returns (GenericDurationData memory result) {
    SkillTemplateDurationData memory uncastResult = SkillTemplateDuration.get(skillEntity);
    assembly {
      result := uncastResult
    }
  }

  function setSkillTemplateDuration(bytes32 skillEntity, GenericDurationData memory uncastData) internal {
    SkillTemplateDurationData memory data;
    assembly {
      data := uncastData
    }
    SkillTemplateDuration.set(skillEntity, data);
  }

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
    if (Duration.has(SkillCooldown._tableId, userEntity, skillEntity)) {
      revert LibSkill_SkillOnCooldown();
    }
    // Verify self-only skill
    if (skill.targetType == TargetType.SELF && userEntity != targetEntity) {
      revert LibSkill_InvalidSkillTarget();
    }
    // TODO verify other target types?

    // Start cooldown
    GenericDurationData memory cooldown = getSkillTemplateCooldown(skillEntity);
    if (cooldown.timeValue > 0) {
      Duration.increase(SkillCooldown._tableId, userEntity, skillEntity, cooldown);
    }

    // Check and subtract skill cost
    uint32 manaCurrent = LibCharstat.getManaCurrent(userEntity);
    if (skill.cost > manaCurrent) {
      revert LibSkill_NotEnoughMana();
    } else if (skill.cost > 0) {
      LibCharstat.setManaCurrent(userEntity, manaCurrent - skill.cost);
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
      GenericDurationData memory duration = getSkillTemplateDuration(skillEntity);
      LibEffect.applyTimedEffect(targetEntity, skillEntity, duration);
    }
  }
}
