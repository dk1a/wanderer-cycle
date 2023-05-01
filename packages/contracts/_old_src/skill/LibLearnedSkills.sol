// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { LearnedSkillsComponent, ID as LearnedSkillsComponentID } from "./LearnedSkillsComponent.sol";

import { SkillType } from "./SkillPrototypeComponent.sol";
import { LibSkill } from "./LibSkill.sol";

library LibLearnedSkills {
  using LibSkill for LibSkill.Self;

  error LibLearnedSkills__LearnSkillDuplicate();

  struct Self {
    IWorld world;
    LearnedSkillsComponent comp;
    uint256 userEntity;
  }

  function __construct(IWorld world, uint256 userEntity) internal view returns (Self memory) {
    IUint256Component components = world.components();
    return
      Self({
        world: world,
        comp: LearnedSkillsComponent(getAddressById(components, LearnedSkillsComponentID)),
        userEntity: userEntity
      });
  }

  function hasSkill(Self memory __self, uint256 skillEntity) internal view returns (bool) {
    return __self.comp.hasItem(__self.userEntity, skillEntity);
  }

  /**
   * @dev Add `skillEntity` to set of learned skills, revert if it's already learned
   */
  function learnSkill(Self memory __self, uint256 skillEntity) internal {
    if (__self.comp.hasItem(__self.userEntity, skillEntity)) {
      revert LibLearnedSkills__LearnSkillDuplicate();
    }

    __self.comp.addItem(__self.userEntity, skillEntity);

    _autotoggleIfPassive(__self, skillEntity);
  }

  /**
   * @dev Copy skills from source to target. Overwrites target's existing skills
   */
  function copySkills(Self memory __self, uint256 sourceEntity) internal {
    if (__self.comp.has(sourceEntity)) {
      uint256[] memory skillEntities = __self.comp.getValue(sourceEntity);
      __self.comp.set(__self.userEntity, skillEntities);

      for (uint256 i; i < skillEntities.length; i++) {
        _autotoggleIfPassive(__self, skillEntities[i]);
      }
    }
  }

  function _autotoggleIfPassive(Self memory __self, uint256 skillEntity) private {
    LibSkill.Self memory libSkill = LibSkill.__construct(__self.world, __self.userEntity, skillEntity);
    if (libSkill.skill.skillType == SkillType.PASSIVE) {
      libSkill.useSkill(__self.userEntity);
    }
  }
}
