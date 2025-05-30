// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { CompletedCycleHistory } from "../cycle/codegen/tables/CompletedCycleHistory.sol";

import { learnSkillSystem } from "../skill/codegen/systems/LearnSkillSystemLib.sol";
import { wheelSystem } from "../wheel/codegen/systems/WheelSystemLib.sol";

import { IDENTITY_INCREMENT } from "../wheel/constants.sol";
import { LibCycle } from "../cycle/LibCycle.sol";
import { LibSkill } from "../skill/LibSkill.sol";
import { ERC721Namespaces } from "../erc721-puppet/ERC721Namespaces.sol";

contract PermSkillSystem is System {
  error PermSkillSystem_NoPreviousCycle();
  error PermSkillSystem_SkillNotLearnedInLastCompletedCycle(bytes32 prevCycleEntity);
  error PermSkillSystem_NotEnoughIdentity();

  function permSkill(bytes32 wandererEntity, bytes32 skillEntity) public {
    // Check permission
    uint256 tokenId = uint256(wandererEntity);
    ERC721Namespaces.Wanderer.checkAuthorized(_msgSender(), tokenId);

    // Must be called outside of a cycle
    LibCycle.requireNotActiveCycle(wandererEntity);

    // Must have cycle completion history to draw the last completed cycle from
    uint256 completionHistoryLength = CompletedCycleHistory.length(wandererEntity);
    if (completionHistoryLength == 0) {
      revert PermSkillSystem_NoPreviousCycle();
    }
    bytes32 prevCycleEntity = CompletedCycleHistory.getItem(wandererEntity, completionHistoryLength - 1);
    // Must have learned the skill during the last completed cycle
    if (!LibSkill.hasSkill(prevCycleEntity, skillEntity)) {
      revert PermSkillSystem_SkillNotLearnedInLastCompletedCycle(prevCycleEntity);
    }

    // Subtract identity cost
    wheelSystem.subtractIdentity(wandererEntity, IDENTITY_INCREMENT);

    // Learn the skill
    learnSkillSystem.learnSkill(wandererEntity, skillEntity);
  }
}
