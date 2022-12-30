// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { LearnedSkillsComponent, ID as LearnedSkillsComponentID } from "./LearnedSkillsComponent.sol";

library LibLearnedSkills {
  error LibLearnedSkills__LearnSkillDuplicate();

  struct Self {
    LearnedSkillsComponent comp;
    uint256 entity;
  }

  function __construct(
    IUint256Component components,
    uint256 entity
  ) internal view returns (Self memory) {
    return Self({
      comp: LearnedSkillsComponent(getAddressById(components, LearnedSkillsComponentID)),
      entity: entity
    });
  }

  function hasSkill(
    Self memory __self,
    uint256 skillEntity
  ) internal view returns (bool) {
    return __self.comp.hasItem(__self.entity, skillEntity);
  }

  /**
   * @dev Add `skillEntity` to set of learned skills, revert if it's already learned
   */
  function learnSkill(
    Self memory __self,
    uint256 skillEntity
  ) internal {
    if (__self.comp.hasItem(__self.entity, skillEntity)) {
      revert LibLearnedSkills__LearnSkillDuplicate();
    }

    __self.comp.addItem(__self.entity, skillEntity);
  }

  /**
   * @dev Copy skills from source to target. Overwrites target's existing skills
   */
  function copySkills(
    Self memory __self,
    uint256 sourceEntity
  ) internal {
    __self.comp.set(
      __self.entity,
      __self.comp.getValue(sourceEntity)
    );
  }
}