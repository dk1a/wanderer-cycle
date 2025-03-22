// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { randomEquipmentSystem } from "../codegen/systems/RandomEquipmentSystemLib.sol";

import { PStat_length } from "../../../CustomTypes.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibActiveCombat } from "../combat/LibActiveCombat.sol";
import { LibCycleCombatRewardRequest } from "./LibCycleCombatRewardRequest.sol";
import { LibExperience } from "../charstat/LibExperience.sol";
import { LibLootOwner } from "../loot/LibLootOwner.sol";
import { LibGuiseLevel } from "../guise/LibGuiseLevel.sol";
import { LibRNG } from "../rng/LibRNG.sol";

contract CycleCombatRewardSystem is System {
  function claimCycleCombatReward(bytes32 wandererEntity, bytes32 requestId) public {
    // Reverts if sender doesn't have permission
    bytes32 cycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);
    // TODO decide if claiming exp during combat is actually bad and why
    LibActiveCombat.requireNotActiveCombat(cycleEntity);

    (
      uint256 randomness,
      uint32[PStat_length] memory exp,
      uint32 lootIlvl,
      uint256 lootCount
    ) = LibCycleCombatRewardRequest.popReward(cycleEntity, requestId);

    // Multiply awarded exp by guise's multiplier
    exp = LibGuiseLevel.multiplyExperience(cycleEntity, exp);

    // Give exp
    LibExperience.increaseExp(cycleEntity, exp);

    // Give loot
    for (uint256 i; i < lootCount; i++) {
      bytes32 lootEntity = randomEquipmentSystem.callAsRootFrom(address(this)).mintRandomEquipmentEntity(
        lootIlvl,
        randomness
      );
      LibLootOwner.setSimpleOwnership(lootEntity, cycleEntity);
    }
  }

  function cancelCycleCombatReward(bytes32 wandererEntity, bytes32 requestId) public {
    // Reverts if sender doesn't have permission
    bytes32 cycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);
    // Remove the reward without claiming it
    LibRNG.removeRequest(cycleEntity, requestId);
  }
}
