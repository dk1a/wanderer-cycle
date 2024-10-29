// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { ActiveGuise, SkillTemplate, GuiseSkills } from "../codegen/index.sol";

import { LibLearnedSkills } from "../skill/LibLearnedSkills.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibGuiseLevel } from "../guise/LibGuiseLevel.sol";

/// @title Learn a Skill from the current cycle Guise's set of available skills.
contract LearnCycleSkillSystem is System {
  error LearnCycleSkillSystem_SkillNotInGuiseSkills();
  error LearnCycleSkillSystem_LevelIsTooLow();

  function learnFromCycle(bytes32 wandererEntity, bytes32 skillEntity) public {
    // get cycle entity if sender is allowed to use it
    bytes32 cycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);

    // check skill's level requirements
    uint32 currentLevel = LibGuiseLevel.getAggregateLevel(cycleEntity);
    uint8 requiredLevel = SkillTemplate.getRequiredLevel(skillEntity);
    if (currentLevel < requiredLevel) {
      revert LearnCycleSkillSystem_LevelIsTooLow();
    }

    // guise skills must include `skillEntity`
    bytes32 guiseProtoEntity = ActiveGuise.get(cycleEntity);
    bytes32[] memory skills = GuiseSkills.get(guiseProtoEntity);

    bool res = false;
    for (uint i = 0; i < skills.length; i++) {
      if (skills[i] == skillEntity) {
        res = true;
        break;
      }
    }

    if (!res) {
      revert LearnCycleSkillSystem_SkillNotInGuiseSkills();
    }
    // learn the skill
    LibLearnedSkills.learnSkill(cycleEntity, skillEntity);
  }
}
