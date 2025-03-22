// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { BossesDefeated } from "../codegen/index.sol";

import { LibCycle } from "./LibCycle.sol";
import { LibGuiseLevel } from "../guise/LibGuiseLevel.sol";
import { LibWanderer } from "../wanderer/LibWanderer.sol";

/**
 * @title Complete a cycle and gain rewards.
 */
contract CompleteCycleSystem is System {
  error CompleteCycleSystem_NotAllBossesDefeated();
  error CompleteCycleSystem_InsufficientLevel();

  function completeCycle(bytes32 wandererEntity) public returns (bytes32 cycleEntity) {
    // Reverts if sender doesn't have permission
    bytes32 cycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);

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

    // Complete cycle
    LibCycle.endCycle(wandererEntity, cycleEntity);
    LibWanderer.gainCycleRewards(wandererEntity);
  }
}
