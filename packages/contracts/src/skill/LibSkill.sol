// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibLearnedSkills } from "./LibLearnedSkills.sol";
import { SkillTemplate, SkillTemplateTableId, SkillTemplateData, LearnedSkills, EffectDuration, EffectTemplate, DurationIdxMap, ManaCurrent, LifeCurrent, GenericDurationData } from "../codegen/index.sol";
import { LibEffect } from "../modules/effect/LibEffect.sol";
import { SkillType, TargetType } from "../codegen/common.sol";
import { LibEffectPrototype } from "../effect/LibEffectPrototype.sol";
import { Duration } from "../modules/duration/Duration.sol";

library LibSkill {
  error LibSkill__SkillMustBeLearned();
  error LibSkill__SkillOnCooldown();
  error LibSkill__NotEnoughMana();
  error LibSkill__InvalidSkillTarget();
  error LibSkill__RequiredCombat();
  error LibSkill__RequiredNonCombat();

  //    return
  //      Self({
  //      world: world,
  //      protoComp: protoComp,
  //      charstat: LibCharstat.__construct(components, userEntity),
  //      learnedSkills: LibLearnedSkills.__construct(world, userEntity),
  //      userEntity: userEntity,
  //      skillEntity: skillEntity,
  //      skill: protoComp.getValue(skillEntity)
  //    });
  //  }

  /**
   * @dev Change Self to use a different skill prototype
   */
  function switchSkill(bytes32 skillEntity) internal view returns (SkillTemplateData memory skill) {
    skill = SkillTemplate.get(skillEntity);
    return skill;
  }

  function requireCombat(bytes32 skillEntity) internal pure {
    if (SkillTemplate.getSkillType(skillEntity) != SkillType.COMBAT) {
      revert LibSkill__RequiredCombat();
    }
  }

  function requireNonCombat(bytes32 skillEntity) internal pure {
    if (SkillTemplate.getSkillType(skillEntity) == SkillType.COMBAT) {
      revert LibSkill__RequiredNonCombat();
    }
  }

  /**
   * @dev Combat skills may target either self or enemy, depending on skill prototype
   */
  function chooseCombatTarget(
    bytes32 enemyEntity,
    bytes32 userEntity,
    bytes32 skillEntity
  ) internal pure returns (bytes32) {
    TargetType targetType = SkillTemplate.getTargetType(skillEntity);
    if (targetType == TargetType.SELF || targetType == TargetType.SELF_OR_ALLY) {
      // self
      return userEntity;
    } else if (targetType == TargetType.ENEMY) {
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
    bytes32 userEntity,
    bytes32 skillEntity,
    bytes32 targetEntity,
    bytes32 timeId,
    uint256 timeValue
  ) internal {
    // must be learned
    if (!LibLearnedSkills.hasSkill(userEntity, skillEntity)) {
      revert LibSkill__SkillMustBeLearned();
    }
    // must be off cooldown
    if (DurationIdxMap.getHas(SkillTemplateTableId, targetEntity, skillEntity)) {
      revert LibSkill__SkillOnCooldown();
    }
    // verify self-only skill
    if (SkillTemplate.getTargetType(skillEntity) == TargetType.SELF & userEntity != targetEntity) {
      revert LibSkill__InvalidSkillTarget();
    }
    // TODO verify other target types?

    // start cooldown
    // (doesn't clash with skill effect duration, which has its own entity)
    if (Duration.getTimeValue(SkillTemplateTableId, targetEntity, skillEntity) > 0) {
      Duration.increase(
        SkillTemplateTableId,
        targetEntity,
        skillEntity,
        GenericDurationData({ timeId: timeId, timeValue: timeValue })
      );
    }

    // check and subtract skill cost
    uint32 manaCurrent = LibCharstat.getManaCurrent(targetEntity);
    uint32 cost = SkillTemplate.getCost(skillEntity);
    if (cost > manaCurrent) {
      revert LibSkill__NotEnoughMana();
    } else if (cost > 0) {
      LibCharstat.setManaCurrent(skillEntity, manaCurrent - cost);
    }

    _applySkillEffect(targetEntity, skillEntity);
  }

  function _applySkillEffect(bytes32 targetEntity, bytes32 skillEntity) private {
    if (!LibEffect.hasEffectTemplate(skillEntity)) {
      // skip if skill has no effect
      return;
    }

    if (SkillTemplate.getTargetType(skillEntity) == SkillType.PASSIVE) {
      // toggle passive skill
      if (LibEffect.hasEffectApplied(targetEntity, skillEntity)) {
        LibEffect.remove(targetEntity, skillEntity);
      } else {
        LibEffect.applyEffect(targetEntity, skillEntity);
      }
    } else {
      // apply active skill
      GenericDurationData memory duration = Duration.get(SkillTemplateTableId, targetEntity, skillEntity);
      LibEffect.applyTimedEffect(targetEntity, skillEntity, duration);
    }
  }
}
