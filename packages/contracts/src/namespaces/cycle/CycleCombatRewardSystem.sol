// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { charstatSystem } from "../charstat/codegen/systems/CharstatSystemLib.sol";
import { randomEquipmentSystem } from "../loot/codegen/systems/RandomEquipmentSystemLib.sol";
import { rNGSystem } from "../rng/codegen/systems/RNGSystemLib.sol";

import { PStat_length } from "../../CustomTypes.sol";
import { LibGuiseLevel } from "../root/guise/LibGuiseLevel.sol";
import { LibActiveCombat } from "../combat/LibActiveCombat.sol";
import { LibCycleCombatRewardRequest } from "./LibCycleCombatRewardRequest.sol";
import { LibLootOwner } from "../loot/LibLootOwner.sol";
import { LibCycle } from "./LibCycle.sol";

contract CycleCombatRewardSystem is System {
  function claimCycleCombatReward(bytes32 cycleEntity, bytes32 requestId) public {
    LibCycle.requireAccess(cycleEntity);

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
    charstatSystem.increaseExp(cycleEntity, exp);

    // Give loot
    for (uint256 i; i < lootCount; i++) {
      bytes32 lootEntity = randomEquipmentSystem.mintRandomEquipmentEntity(lootIlvl, randomness);
      LibLootOwner.setSimpleOwnership(lootEntity, cycleEntity);
    }
  }

  function cancelCycleCombatReward(bytes32 cycleEntity, bytes32 requestId) public {
    LibCycle.requireAccess(cycleEntity);

    // Remove the reward without claiming it
    rNGSystem.removeRequest(cycleEntity, requestId);
  }
}
