// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { CycleBossesDefeatedComponent, ID as CycleBossesDefeatedComponentID } from "./CycleBossesDefeatedComponent.sol";

import { LibCycle } from "./LibCycle.sol";
import { LibToken } from "../token/LibToken.sol";
import { LibGuiseLevel } from "../guise/LibGuiseLevel.sol";
import { LibWanderer } from "../wanderer/LibWanderer.sol";

uint256 constant ID = uint256(keccak256("system.CompleteCycle"));

/// @title Complete a cycle and gain rewards.
contract CompleteCycleSystem is System {
  error CompleteCycleSystem__NotAllBossesDefeated();
  error CompleteCycleSystem__InsufficientLevel();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(uint256 wandererEntity) public returns (uint256 cycleEntity) {
    return abi.decode(execute(abi.encode(wandererEntity)), (uint256));
  }

  function execute(bytes memory args) public override returns (bytes memory) {
    uint256 wandererEntity = abi.decode(args, (uint256));

    // reverts if sender doesn't have permission
    uint256 cycleEntity = LibCycle.getCycleEntityPermissioned(components, wandererEntity);

    // All bosses must be defeated
    CycleBossesDefeatedComponent cycleBossesDefeated = CycleBossesDefeatedComponent(
      getAddressById(components, CycleBossesDefeatedComponentID)
    );
    // TODO requirement reduced for testing; remove hardcode
    if (cycleBossesDefeated.itemSetSize(cycleEntity) < 0) {
      revert CompleteCycleSystem__NotAllBossesDefeated();
    }

    // must be max level
    // TODO requirement reduced for testing; also remove hardcode
    uint32 level = LibGuiseLevel.getAggregateLevel(components, cycleEntity);
    if (level < 1) {
      revert CompleteCycleSystem__InsufficientLevel();
    }

    // complete cycle
    LibCycle.endCycle(components, wandererEntity, cycleEntity);
    LibWanderer.gainCycleRewards(components, wandererEntity);

    return abi.encode(cycleEntity);
  }
}
