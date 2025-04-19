// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { GuiseSkills } from "../root/codegen/tables/GuiseSkills.sol";
import { SkillTemplate } from "../skill/codegen/tables/SkillTemplate.sol";
import { ActiveGuise } from "./codegen/tables/ActiveGuise.sol";

import { learnSkillSystem } from "../skill/codegen/systems/LearnSkillSystemLib.sol";

import { LibGuiseLevel } from "../root/guise/LibGuiseLevel.sol";
import { LibCycle } from "./LibCycle.sol";

/**
 * @title Learn a Skill from the current cycle Guise's set of available skills.
 */
contract CycleLearnSkillSystem is System {
  error CycleLearnSkillSystem_SkillNotInGuiseSkills(bytes32 skillEntity, bytes32 guiseEntity);
  error CycleLearnSkillSystem_LevelIsTooLow(uint32 currentLevel, uint32 requiredLevel);

  function learnSkill(bytes32 cycleEntity, bytes32 skillEntity) public {
    LibCycle.requireAccess(cycleEntity);

    // Check skill's level requirements
    uint32 currentLevel = LibGuiseLevel.getAggregateLevel(cycleEntity);
    uint8 requiredLevel = SkillTemplate.getRequiredLevel(skillEntity);
    // TODO remove false, this is just for skill testing purposes
    if (false && currentLevel < requiredLevel) {
      revert CycleLearnSkillSystem_LevelIsTooLow(currentLevel, requiredLevel);
    }

    // Guise skills must include `skillEntity`
    bytes32 guiseEntity = ActiveGuise.get(cycleEntity);
    bytes32[] memory skills = GuiseSkills.get(guiseEntity);

    bool res = false;
    for (uint i = 0; i < skills.length; i++) {
      if (skills[i] == skillEntity) {
        res = true;
        break;
      }
    }

    if (!res) {
      revert CycleLearnSkillSystem_SkillNotInGuiseSkills(skillEntity, guiseEntity);
    }
    // Learn the skill
    learnSkillSystem.learnSkill(cycleEntity, skillEntity);
  }
}
