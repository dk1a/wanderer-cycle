// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { BossesDefeated } from "./codegen/tables/BossesDefeated.sol";

import { initCycleSystem } from "./codegen/systems/InitCycleSystemLib.sol";

import { LibCycle } from "./LibCycle.sol";
import { LibGuiseLevel } from "../root/guise/LibGuiseLevel.sol";
import { ERC721Namespaces } from "../erc721-puppet/ERC721Namespaces.sol";

contract CycleControlSystem is System {
  error CompleteCycleSystem_NotAllBossesDefeated();
  error CompleteCycleSystem_InsufficientLevel();

  function startCycle(
    bytes32 wandererEntity,
    bytes32 guiseEntity,
    bytes32 wheelEntity
  ) public returns (bytes32 cycleEntity) {
    // Check permission
    ERC721Namespaces.WandererNFT.requireOwner(_msgSender(), wandererEntity);
    // Init cycle (reverts if a cycle is already active)
    cycleEntity = initCycleSystem.initCycle(wandererEntity, guiseEntity, wheelEntity);
  }

  function cancelCycle(bytes32 cycleEntity) public {
    LibCycle.requireAccess(cycleEntity);

    LibCycle.cancelCycle(cycleEntity);
  }

  function completeCycle(bytes32 cycleEntity) public {
    LibCycle.requireAccess(cycleEntity);

    // All bosses must be defeated
    // TODO requirement reduced for testing; remove hardcode
    if (BossesDefeated.length(cycleEntity) < 0) {
      revert CompleteCycleSystem_NotAllBossesDefeated();
    }

    // Must be max level
    // TODO requirement reduced for testing; also remove hardcode
    uint32 level = LibGuiseLevel.getAggregateLevel(cycleEntity);
    if (level < 1) {
      revert CompleteCycleSystem_InsufficientLevel();
    }

    // Complete the cycle
    LibCycle.completeCycle(cycleEntity);
  }
}
