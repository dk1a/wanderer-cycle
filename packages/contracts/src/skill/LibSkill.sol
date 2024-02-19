// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

//import { EffectSubSystem, ID as EffectSubSystemID } from "../effect/EffectSubSystem.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibLearnedSkills } from "./LibLearnedSkills.sol";
import { SkillTemplate, SkillTemplateTableId, SkillTemplateData, LearnedSkills, EffectDuration, EffectTemplate, DurationIdxMap, ManaCurrent, LifeCurrent } from "../codegen/tables/StatmodBase.sol";

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
  //  function switchSkill(bytes32 skillEntity) internal view {
  //    __self.skillEntity = skillEntity;
  //    __self.skill = __self.protoComp.getValue(skillEntity);
  //    return __self;
  //  }

  //  function requireCombat(bytes32 skillEntity) internal pure {
  //    if (skill.skillType != SkillType.COMBAT) {
  //      revert LibSkill__RequiredCombat();
  //    }
  //  }

  //  function requireNonCombat(bytes32 skillEntity) internal pure {
  //    if (skill.skillType == SkillType.COMBAT) {
  //      revert LibSkill__RequiredNonCombat();
  //    }
  //  }

  /**
   * @dev Combat skills may target either self or enemy, depending on skill prototype
   */
  //  function chooseCombatTarget(bytes32 enemyEntity, bytes32 userEntity) internal pure returns (uint256) {
  //    if (skill.effectTarget == TargetType.SELF || skill.effectTarget == TargetType.SELF_OR_ALLY) {
  //      // self
  //      return userEntity;
  //    } else if (skill.effectTarget == TargetType.ENEMY) {
  //      // enemy
  //      return enemyEntity;
  //    } else {
  //      revert LibSkill__InvalidSkillTarget();
  //    }
  //  }

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
    //    if (__self.skill.effectTarget == TargetType.SELF && __self.userEntity != targetEntity) {
    //      revert LibSkill__InvalidSkillTarget();
    //    }
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
      LibCharstat.setManaCurrent(manaCurrent - cost);
    }

    //    _applySkillEffect(__self, targetEntity);
  }

  //  function _applySkillEffect(bytes32 targetEntity, bytes32 skillEntity) private {
  //    if (!effectSubSystem.isEffectPrototype(skillEntity)) {
  //      // skip if skill has no effect
  //      return;
  //    }
  //
  //    if (skill.skillType == SkillType.PASSIVE) {
  //      // toggle passive skill
  //      if (effectSubSystem.has(targetEntity, skillEntity)) {
  //        effectSubSystem.executeRemove(targetEntity, skillEntity);
  //      } else {
  //        effectSubSystem.executeApply(targetEntity, skillEntity);
  //      }
  //    } else {
  //      // apply active skill
  //      effectSubSystem.executeApplyTimed(targetEntity, skillEntity, skill.duration);
  //    }
  //  }
}
