// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { ActiveCycleComponent, ID as ActiveCycleComponentID } from "../cycle/ActiveCycleComponent.sol";
import { ActiveCyclePreviousComponent, ID as ActiveCyclePreviousComponentID } from "../cycle/ActiveCyclePreviousComponent.sol";
import { LearnedSkillsComponent, ID as LearnedSkillsComponentID } from "../skill/LearnedSkillsComponent.sol";
import { IdentityComponent, ID as IdentityComponentID } from "./IdentityComponent.sol";

import { LibLearnedSkills } from "../skill/LibLearnedSkills.sol";
import { LibToken } from "../token/LibToken.sol";

uint256 constant ID = uint256(keccak256("system.PermSkill"));

/// @title Make a skill permanent
contract PermSkillSystem is System {
  using LibLearnedSkills for LibLearnedSkills.Self;

  uint32 internal constant PERM_SKILL_IDENTITY_COST = 128;

  error PermSkillSystem__MustHaveNoActiveCycle();
  error PermSkillSystem__SkillNotLearnedInPreviousCycle(uint256 previousCycleEntity);
  error PermSkillSystem__NotEnoughIdentity();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(uint256 wandererEntity, uint256 skillEntity) public {
    execute(abi.encode(wandererEntity, skillEntity));
  }

  function execute(bytes memory args) public override returns (bytes memory) {
    (uint256 wandererEntity, uint256 skillEntity) = abi.decode(args, (uint256, uint256));

    ActiveCycleComponent activeCycleComp = ActiveCycleComponent(getAddressById(components, ActiveCycleComponentID));
    ActiveCyclePreviousComponent activeCyclePreviousComp = ActiveCyclePreviousComponent(
      getAddressById(components, ActiveCyclePreviousComponentID)
    );
    LearnedSkillsComponent learnedSkillsComp = LearnedSkillsComponent(
      getAddressById(components, LearnedSkillsComponentID)
    );
    IdentityComponent identityComponent = IdentityComponent(getAddressById(components, IdentityComponentID));

    // caller must own the wanderer
    LibToken.requireOwner(components, wandererEntity, msg.sender);

    // must be called outside of a cycle
    if (activeCycleComp.has(wandererEntity)) {
      revert PermSkillSystem__MustHaveNoActiveCycle();
    }

    // must have learned the skill during the previous cycle
    uint256 prevCycleEntity = activeCyclePreviousComp.getValue(wandererEntity);
    if (!learnedSkillsComp.hasItem(prevCycleEntity, skillEntity)) {
      revert PermSkillSystem__SkillNotLearnedInPreviousCycle(prevCycleEntity);
    }

    // subtract identity cost
    uint32 currentIdentity = identityComponent.getValue(wandererEntity);
    if (currentIdentity < PERM_SKILL_IDENTITY_COST) {
      revert PermSkillSystem__NotEnoughIdentity();
    }
    identityComponent.set(wandererEntity, currentIdentity - PERM_SKILL_IDENTITY_COST);

    // learn the skill
    LibLearnedSkills.__construct(world, wandererEntity).learnSkill(skillEntity);

    return "";
  }
}
