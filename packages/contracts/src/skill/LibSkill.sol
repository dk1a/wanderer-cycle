// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { DurationSubSystem, ID as DurationSubSystemID, ScopedDuration, SystemCallback } from "../duration/DurationSubSystem.sol";
import { EffectSubSystem, ID as EffectSubSystemID } from "../effect/EffectSubSystem.sol";
import { EffectPrototypeComponent, ID as EffectPrototypeComponentID } from "../effect/EffectPrototypeComponent.sol";
import { LearnedSkillsComponent, ID as LearnedSkillsComponentID } from "./LearnedSkillsComponent.sol";
import { LibLearnedSkills } from "./LibLearnedSkills.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { SkillType, TargetType, SkillPrototype, SkillPrototypeComponent, ID as SkillPrototypeComponentID } from "./SkillPrototypeComponent.sol";

library LibSkill {
  using LibCharstat for LibCharstat.Self;
  using LibLearnedSkills for LibLearnedSkills.Self;

  error LibSkill__SkillMustBeLearned();
  error LibSkill__SkillOnCooldown();
  error LibSkill__NotEnoughMana();
  error LibSkill__InvalidSkillTarget();
  error LibSkill__RequiredCombat();
  error LibSkill__RequiredNonCombat();

  struct Self {
    IWorld world;
    SkillPrototypeComponent protoComp;
    LibCharstat.Self charstat;
    LibLearnedSkills.Self learnedSkills;
    uint256 userEntity;
    uint256 skillEntity;
    SkillPrototype skill;
  }

  function __construct(IWorld world, uint256 userEntity, uint256 skillEntity) internal view returns (Self memory) {
    IUint256Component components = world.components();
    SkillPrototypeComponent protoComp = SkillPrototypeComponent(getAddressById(components, SkillPrototypeComponentID));

    return
      Self({
        world: world,
        protoComp: protoComp,
        charstat: LibCharstat.__construct(components, userEntity),
        learnedSkills: LibLearnedSkills.__construct(components, userEntity),
        userEntity: userEntity,
        skillEntity: skillEntity,
        skill: protoComp.getValue(skillEntity)
      });
  }

  /**
   * @dev Change Self to use a different Skill prototype
   */
  function switchSkill(Self memory __self, uint256 skillEntity) internal view returns (Self memory) {
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
   * @dev Combat skills may target either self or enemy, depending on Skill prototype
   */
  function chooseCombatTarget(Self memory __self, uint256 enemyEntity) internal pure returns (uint256) {
    if (__self.skill.effectTarget == TargetType.SELF || __self.skill.effectTarget == TargetType.SELF_OR_ALLY) {
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
  function useSkill(Self memory __self, uint256 targetEntity) internal {
    // must be learned
    if (!__self.learnedSkills.hasSkill(__self.skillEntity)) {
      revert LibSkill__SkillMustBeLearned();
    }
    // must be off cooldown
    DurationSubSystem durationSubSystem = DurationSubSystem(
      getAddressById(__self.world.systems(), DurationSubSystemID)
    );
    if (durationSubSystem.has(targetEntity, __self.skillEntity)) {
      revert LibSkill__SkillOnCooldown();
    }
    // verify self-only Skill
    if (__self.skill.effectTarget == TargetType.SELF && __self.userEntity != targetEntity) {
      revert LibSkill__InvalidSkillTarget();
    }
    // TODO verify other target types?

    // start cooldown
    // (doesn't clash with Skill effect duration, which has its own entity)
    durationSubSystem.executeIncrease(targetEntity, __self.skillEntity, __self.skill.cooldown, SystemCallback(0, ""));

    // check and subtract Skill cost
    uint32 manaCurrent = __self.charstat.getManaCurrent();
    if (__self.skill.cost > manaCurrent) {
      revert LibSkill__NotEnoughMana();
    } else {
      __self.charstat.setManaCurrent(manaCurrent - __self.skill.cost);
    }

    _applySkillEffect(__self, targetEntity);
  }

  function _applySkillEffect(Self memory __self, uint256 targetEntity) private {
    EffectSubSystem effectSubSystem = EffectSubSystem(getAddressById(__self.world.systems(), EffectSubSystemID));

    if (!effectSubSystem.isEffectPrototype(__self.skillEntity)) {
      // skip if Skill has no effect
      return;
    }

    if (__self.skill.skillType == SkillType.PASSIVE) {
      // toggle passive Skill
      if (effectSubSystem.has(targetEntity, __self.skillEntity)) {
        effectSubSystem.executeRemove(targetEntity, __self.skillEntity);
      } else {
        effectSubSystem.executeApply(targetEntity, __self.skillEntity);
      }
    } else {
      // apply active Skill
      effectSubSystem.executeApplyTimed(targetEntity, __self.skillEntity, __self.skill.duration);
    }
  }
}
