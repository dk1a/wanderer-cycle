// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibEffect, EffectDuration, EffectTemplate } from "../effect/LibEffect.sol";
import { Duration, GenericDurationData } from "../duration/Duration.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";

import { SkillTemplate, SkillTemplateData } from "./codegen/tables/SkillTemplate.sol";
import { SkillTemplateCooldown, SkillTemplateCooldownData } from "./codegen/tables/SkillTemplateCooldown.sol";
import { SkillTemplateDuration, SkillTemplateDurationData } from "./codegen/tables/SkillTemplateDuration.sol";
import { SkillCooldown } from "./codegen/tables/SkillCooldown.sol";
import { LearnedSkills } from "./codegen/tables/LearnedSkills.sol";
import { UniqueIdx_SkillName_Name } from "./codegen/idxs/UniqueIdx_SkillName_Name.sol";

import { SkillType, TargetType } from "../../codegen/common.sol";

library LibSkill {
  error LibSkill_NameNotFound(string name);
  error LibSkill_InvalidSkillTarget(bytes32 skillEntity, TargetType targetType);
  error LibSkill_InvalidUserAndTargetCombination(TargetType targetType, bytes32 userEntity, bytes32 targetEntity);
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
   * @dev Verify that the TargetType has meaningful user and target (e.g. entities have to be equal for SELF)
   */
  function verifyTargetType(TargetType targetType, bytes32 userEntity, bytes32 targetEntity) internal pure {
    if (targetType == TargetType.SELF) {
      // Verify self-only targets
      if (userEntity != targetEntity)
        revert LibSkill_InvalidUserAndTargetCombination(targetType, userEntity, targetEntity);
    } else if (targetType == TargetType.ENEMY) {
      // Verify non-self targets
      if (userEntity == targetEntity)
        revert LibSkill_InvalidUserAndTargetCombination(targetType, userEntity, targetEntity);
    }
  }

  function hasSkill(bytes32 userEntity, bytes32 skillEntity) internal view returns (bool) {
    bytes32[] memory userSkills = LearnedSkills.get(userEntity);
    for (uint256 i = 0; i < userSkills.length; i++) {
      if (userSkills[i] == skillEntity) {
        return true;
      }
    }
    return false;
  }
}
