// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibEffect, EffectDuration, EffectTemplate } from "../../effect/LibEffect.sol";
import { Duration, GenericDurationData } from "../../duration/Duration.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibLearnedSkills } from "./LibLearnedSkills.sol";
import { SkillTemplate, SkillTemplateData, SkillTemplateCooldown, SkillTemplateCooldownData, SkillTemplateDuration, SkillTemplateDurationData, SkillCooldown, LearnedSkills, ManaCurrent, LifeCurrent } from "../codegen/index.sol";
import { UniqueIdx_SkillName_Name } from "../codegen/idxs/UniqueIdx_SkillName_Name.sol";
import { SkillType, TargetType } from "../../../codegen/common.sol";

library LibSkill {
  error LibSkill_NameNotFound(string name);
  error LibSkill_SkillMustBeLearned(bytes32 userEntity, bytes32 skillEntity);
  error LibSkill_SkillOnCooldown(bytes32 userEntity, bytes32 skillEntity);
  error LibSkill_NotEnoughMana(uint32 cost, uint32 current);
  error LibSkill_InvalidSkillTarget(bytes32 skillEntity, TargetType targetType);
  error LibSkill_RequiredCombatType(bytes32 skillEntity);
  error LibSkill_RequiredNonCombatType(bytes32 skillEntity);

  function getSkillEntity(string memory name) internal view returns (bytes32 skillEntity) {
    skillEntity = UniqueIdx_SkillName_Name.get(name);
    if (skillEntity == bytes32(0)) {
      revert LibSkill_NameNotFound(name);
    }
  }

  function getSkillTemplateCooldown(bytes32 skillEntity) internal view returns (GenericDurationData memory result) {
    SkillTemplateCooldownData memory uncastResult = SkillTemplateCooldown.get(skillEntity);
    assembly {
      result := uncastResult
    }
  }

  function setSkillTemplateCooldown(bytes32 skillEntity, GenericDurationData memory data) internal {
    SkillTemplateCooldownData memory castData;
    assembly {
      castData := data
    }
    SkillTemplateCooldown.set(skillEntity, castData);
  }

  function getSkillTemplateDuration(bytes32 skillEntity) internal view returns (GenericDurationData memory result) {
    SkillTemplateDurationData memory uncastResult = SkillTemplateDuration.get(skillEntity);
    assembly {
      result := uncastResult
    }
  }

  function setSkillTemplateDuration(bytes32 skillEntity, GenericDurationData memory data) internal {
    SkillTemplateDurationData memory castData;
    assembly {
      castData := data
    }
    SkillTemplateDuration.set(skillEntity, castData);
  }

  function requireCombatType(bytes32 skillEntity) internal view {
    if (SkillTemplate.getSkillType(skillEntity) != SkillType.COMBAT) {
      revert LibSkill_RequiredCombatType(skillEntity);
    }
  }

  function requireNonCombatType(bytes32 skillEntity) internal view {
    if (SkillTemplate.getSkillType(skillEntity) == SkillType.COMBAT) {
      revert LibSkill_RequiredNonCombatType(skillEntity);
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
      revert LibSkill_InvalidSkillTarget(skillEntity, targetType);
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
      revert LibSkill_SkillMustBeLearned(userEntity, skillEntity);
    }
    // Must be off cooldown
    if (Duration.has(SkillCooldown._tableId, userEntity, skillEntity)) {
      revert LibSkill_SkillOnCooldown(userEntity, skillEntity);
    }
    // Verify self-only skill
    if (skill.targetType == TargetType.SELF && userEntity != targetEntity) {
      revert LibSkill_InvalidSkillTarget(skillEntity, skill.targetType);
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
      revert LibSkill_NotEnoughMana(skill.cost, manaCurrent);
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
