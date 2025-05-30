// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { BossesDefeated } from "./codegen/tables/BossesDefeated.sol";
import { RequiredBossMaps } from "./codegen/tables/RequiredBossMaps.sol";

import { initCycleSystem } from "./codegen/systems/InitCycleSystemLib.sol";
import { learnSkillSystem } from "../skill/codegen/systems/LearnSkillSystemLib.sol";

import { LibCycle } from "./LibCycle.sol";
import { LibGuiseLevel } from "../root/guise/LibGuiseLevel.sol";
import { ERC721Namespaces } from "../erc721-puppet/ERC721Namespaces.sol";

contract CycleControlSystem is System {
  error CompleteCycleSystem_NotAllBossesDefeated();
  error CompleteCycleSystem_InsufficientLevel();

  // TODO centralize config constants
  uint256 constant REQUIRED_LEVEL = 12;

  function startCycle(
    bytes32 wandererEntity,
    bytes32 guiseEntity,
    bytes32 wheelEntity
  ) public returns (bytes32 cycleEntity) {
    // Check permission
    uint256 tokenId = uint256(wandererEntity);
    ERC721Namespaces.Wanderer.checkAuthorized(_msgSender(), tokenId);
    // Init cycle (reverts if a cycle is already active)
    cycleEntity = initCycleSystem.initCycle(wandererEntity, guiseEntity, wheelEntity);
    // Copy permanent skills
    learnSkillSystem.copySkills(wandererEntity, cycleEntity);
  }

  function cancelCycle(bytes32 cycleEntity) public {
    LibCycle.requireAccess(cycleEntity);

    LibCycle.cancelCycle(cycleEntity);
  }

  function completeCycle(bytes32 cycleEntity) public {
    LibCycle.requireAccess(cycleEntity);

    // All bosses must be defeated
    if (BossesDefeated.length(cycleEntity) < RequiredBossMaps.length()) {
      revert CompleteCycleSystem_NotAllBossesDefeated();
    }

    // Must be high enough level
    uint32 level = LibGuiseLevel.getAggregateLevel(cycleEntity);
    if (level < REQUIRED_LEVEL) {
      revert CompleteCycleSystem_InsufficientLevel();
    }

    // Complete the cycle
    LibCycle.completeCycle(cycleEntity);
  }

  // TODO for testing only
  function adminCompleteCycle(bytes32 cycleEntity) public {
    LibCycle.requireAccess(cycleEntity);
    LibCycle.completeCycle(cycleEntity);
  }
}
