// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { RandomEquipmentSubSystem, ID as RandomEquipmentSubSystemID } from "../loot/RandomEquipmentSubSystem.sol";

import { LibCycle } from "./LibCycle.sol";
import { LibActiveCombat } from "../combat/LibActiveCombat.sol";
import { LibCycleCombatRewardRequest } from "./LibCycleCombatRewardRequest.sol";
import { LibExperience, PS_L } from "../charstat/LibExperience.sol";
import { LibLootOwner } from "../loot/LibLootOwner.sol";
import { LibGuiseLevel } from "../guise/LibGuiseLevel.sol";
import { LibRNG } from "../rng/LibRNG.sol";

uint256 constant ID = uint256(keccak256("system.CycleCombatReward"));

contract CycleCombatRewardSystem is System {
  using LibExperience for LibExperience.Self;

  error CycleCombatRewardSystem__UnknownMapPrototype();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(uint256 wandererEntity, uint256 requestId) public {
    execute(abi.encode(wandererEntity, requestId));
  }

  function execute(bytes memory args) public override returns (bytes memory) {
    (uint256 wandererEntity, uint256 requestId) = abi.decode(args, (uint256, uint256));
    // reverts if sender doesn't have permission
    uint256 cycleEntity = LibCycle.getCycleEntityPermissioned(components, wandererEntity);
    // TODO decide if claiming exp during combat is actually bad and why
    LibActiveCombat.requireNotActiveCombat(components, cycleEntity);

    (uint256 randomness, uint32[PS_L] memory exp, uint32 lootIlvl, uint256 lootCount) = LibCycleCombatRewardRequest
      .popReward(components, cycleEntity, requestId);

    // multiply awarded exp by guise's multiplier
    exp = LibGuiseLevel.multiplyExperience(components, cycleEntity, exp);

    // give exp
    LibExperience.__construct(components, cycleEntity).increaseExp(exp);

    // give loot
    RandomEquipmentSubSystem randomEquipmentSubSystem = RandomEquipmentSubSystem(
      getAddressById(world.systems(), RandomEquipmentSubSystemID)
    );
    for (uint256 i; i < lootCount; i++) {
      uint256 lootEntity = randomEquipmentSubSystem.executeTyped(lootIlvl, randomness);
      LibLootOwner.setSimpleOwnership(components, lootEntity, cycleEntity);
    }

    return "";
  }

  function cancelRequest(uint256 wandererEntity, uint256 requestId) public {
    // reverts if sender doesn't have permission
    uint256 cycleEntity = LibCycle.getCycleEntityPermissioned(components, wandererEntity);
    // remove the reward without claiming it
    LibRNG.removeRequest(components, cycleEntity, requestId);
  }
}
