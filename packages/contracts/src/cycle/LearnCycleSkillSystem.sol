// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { ActiveGuiseComponent, ID as ActiveGuiseComponentID } from "../guise/ActiveGuiseComponent.sol";
import { GuiseSkillsComponent, ID as GuiseSkillsComponentID } from "../guise/GuiseSkillsComponent.sol";
import { SkillPrototypeComponent, ID as SkillPrototypeComponentID } from "../skill/SkillPrototypeComponent.sol";

import { LibLearnedSkills } from "../skill/LibLearnedSkills.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibGuiseLevel } from "../guise/LibGuiseLevel.sol";

uint256 constant ID = uint256(keccak256("system.LearnCycleSkill"));

/// @title Learn a Skill from the current cycle Guise's set of available skills.
contract LearnCycleSkillSystem is System {
  using LibLearnedSkills for LibLearnedSkills.Self;

  error LearnCycleSkillSystem__SkillNotInGuiseSkills();
  error LearnCycleSkillSystem__LevelIsTooLow();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(uint256 wandererEntity, uint256 skillEntity) public {
    execute(abi.encode(wandererEntity, skillEntity));
  }

  function execute(bytes memory args) public override returns (bytes memory) {
    (uint256 wandererEntity, uint256 skillEntity) = abi.decode(args, (uint256, uint256));

    ActiveGuiseComponent activeGuiseComp = ActiveGuiseComponent(getAddressById(components, ActiveGuiseComponentID));
    SkillPrototypeComponent skillProto = SkillPrototypeComponent(getAddressById(components, SkillPrototypeComponentID));
    GuiseSkillsComponent guiseSkillsComp = GuiseSkillsComponent(getAddressById(components, GuiseSkillsComponentID));

    // get cycle entity if sender is allowed to use it
    uint256 cycleEntity = LibCycle.getCycleEntityPermissioned(components, wandererEntity);

    // check skill's level requirements
    uint32 currentLevel = LibGuiseLevel.getAggregateLevel(components, cycleEntity);
    uint8 requiredLevel = skillProto.getValue(skillEntity).requiredLevel;
    if (currentLevel < requiredLevel) {
      revert LearnCycleSkillSystem__LevelIsTooLow();
    }

    // guise skills must include `skillEntity`
    uint256 guiseProtoEntity = activeGuiseComp.getValue(cycleEntity);
    if (!guiseSkillsComp.hasItem(guiseProtoEntity, skillEntity)) {
      revert LearnCycleSkillSystem__SkillNotInGuiseSkills();
    }

    // learn the skill
    LibLearnedSkills.__construct(world, cycleEntity).learnSkill(skillEntity);

    return "";
  }
}
