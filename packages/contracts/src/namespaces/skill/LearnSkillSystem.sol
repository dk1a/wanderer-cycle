// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { hasKey } from "@latticexyz/world-modules/src/modules/keysintable/hasKey.sol";

import { SkillTemplate, SkillTemplateData } from "./codegen/tables/SkillTemplate.sol";
import { LearnedSkills } from "./codegen/tables/LearnedSkills.sol";
import { skillSystem } from "./codegen/systems/SkillSystemLib.sol";

import { TargetType, SkillType } from "../../codegen/common.sol";

contract LearnSkillSystem is System {
  error LearnSkillSystem_LearnSkillDuplicate();

  /**
   * @dev Add `skillEntity` to set of learned skills, revert if it's already learned
   */
  function learnSkill(bytes32 userEntity, bytes32 skillEntity) public {
    bytes32[] memory userSkills = LearnedSkills.get(userEntity);
    for (uint256 i = 0; i < userSkills.length; i++) {
      if (userSkills[i] == skillEntity) {
        revert LearnSkillSystem_LearnSkillDuplicate();
      }
    }
    LearnedSkills.push(userEntity, skillEntity);
    _autotoggleIfPassive(userEntity, skillEntity);
  }

  /**
   * @dev Copy skills from source to target. Overwrites target's existing skills
   */
  function copySkills(bytes32 sourceEntity, bytes32 targetEntity) public {
    bool isKey = hasKey(LearnedSkills._tableId, LearnedSkills.encodeKeyTuple(targetEntity));
    if (isKey) {
      bytes32[] memory skillEntities = LearnedSkills.get(targetEntity);
      LearnedSkills.set(sourceEntity, skillEntities);

      for (uint256 i; i < skillEntities.length; i++) {
        _autotoggleIfPassive(sourceEntity, skillEntities[i]);
      }
    }
  }

  function _autotoggleIfPassive(bytes32 userEntity, bytes32 skillEntity) internal {
    SkillType skillType = SkillTemplate.getSkillType(skillEntity);
    if (skillType == SkillType.PASSIVE) {
      skillSystem.useSkill(userEntity, skillEntity, userEntity);
    }
  }
}
