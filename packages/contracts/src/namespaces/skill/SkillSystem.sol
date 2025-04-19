// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { SkillTemplate, SkillTemplateData } from "./codegen/tables/SkillTemplate.sol";
import { SkillCooldown } from "./codegen/tables/SkillCooldown.sol";

import { charstatSystem } from "../charstat/codegen/systems/CharstatSystemLib.sol";
import { effectSystem } from "../effect/codegen/systems/EffectSystemLib.sol";

import { LibEffect, EffectDuration, EffectTemplate } from "../effect/LibEffect.sol";
import { Duration, GenericDurationData } from "../duration/Duration.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibSkill } from "./LibSkill.sol";

import { SkillType, TargetType } from "../../codegen/common.sol";

contract SkillSystem is System {
  error SkillSystem_SkillMustBeLearned(bytes32 userEntity, bytes32 skillEntity);
  error SkillSystem_SkillOnCooldown(bytes32 userEntity, bytes32 skillEntity);
  error SkillSystem_NotEnoughMana(uint32 cost, uint32 current);

  /**
   * @dev Check some requirements, subtract cost, start cooldown, apply effect.
   * However this method is NOT combat aware and doesn't do attack/spell damage
   */
  function useSkill(bytes32 userEntity, bytes32 skillEntity, bytes32 targetEntity) public {
    SkillTemplateData memory skill = SkillTemplate.get(skillEntity);

    // Must be learned
    if (!LibSkill.hasSkill(userEntity, skillEntity)) {
      revert SkillSystem_SkillMustBeLearned(userEntity, skillEntity);
    }
    // Must be off cooldown
    if (Duration.has(SkillCooldown._tableId, userEntity, skillEntity)) {
      revert SkillSystem_SkillOnCooldown(userEntity, skillEntity);
    }
    // User and target entities must be valid for skill's targetType
    LibSkill.verifyTargetType(skill.targetType, userEntity, targetEntity);

    // Start cooldown
    GenericDurationData memory cooldown = LibSkill.getSkillTemplateCooldown(skillEntity);
    if (cooldown.timeValue > 0) {
      Duration.increase(SkillCooldown._tableId, userEntity, skillEntity, cooldown);
    }

    // Check and subtract skill cost
    uint32 manaCurrent = LibCharstat.getManaCurrent(userEntity);
    if (skill.cost > manaCurrent) {
      revert SkillSystem_NotEnoughMana(skill.cost, manaCurrent);
    } else if (skill.cost > 0) {
      charstatSystem.setManaCurrent(userEntity, manaCurrent - skill.cost);
    }

    _applySkillEffect(skillEntity, skill, targetEntity);
  }

  function _applySkillEffect(bytes32 skillEntity, SkillTemplateData memory skill, bytes32 targetEntity) internal {
    if (!LibEffect.hasEffectTemplate(skillEntity)) {
      // skip if skill has no effect
      return;
    }

    if (skill.skillType == SkillType.PASSIVE) {
      // toggle passive skill
      if (LibEffect.hasEffectApplied(targetEntity, skillEntity)) {
        effectSystem.remove(targetEntity, skillEntity);
      } else {
        effectSystem.applyEffect(targetEntity, skillEntity);
      }
    } else {
      // apply active skill
      GenericDurationData memory duration = LibSkill.getSkillTemplateDuration(skillEntity);
      effectSystem.applyTimedEffect(targetEntity, skillEntity, duration);
    }
  }
}
