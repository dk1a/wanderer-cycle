// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { CycleCombatRReq } from "./codegen/tables/CycleCombatRReq.sol";
import { CombatRewardLogOffchain, CombatRewardLogOffchainData } from "./codegen/tables/CombatRewardLogOffchain.sol";

import { charstatSystem } from "../charstat/codegen/systems/CharstatSystemLib.sol";
import { randomEquipmentSystem } from "../loot/codegen/systems/RandomEquipmentSystemLib.sol";
import { randomnessSystem } from "../rng/codegen/systems/RandomnessSystemLib.sol";

import { PStat_length } from "../../CustomTypes.sol";
import { LibGuiseLevel } from "../root/guise/LibGuiseLevel.sol";
import { LibCycleCombatRewardRequest } from "./LibCycleCombatRewardRequest.sol";
import { LibLootOwner } from "../loot/LibLootOwner.sol";
import { LibCycle } from "./LibCycle.sol";
import { LibActiveCombat } from "./LibActiveCombat.sol";

contract CycleCombatRewardSystem is System {
  function claimCycleCombatReward(bytes32 cycleEntity, bytes32 requestId) public {
    LibCycle.requireAccess(cycleEntity);

    // TODO decide if claiming exp during combat is actually bad and why
    LibActiveCombat.requireNotActiveCombat(cycleEntity);

    bytes32 combatEntity = CycleCombatRReq.getCombatEntity(requestId);
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
    bytes32[] memory lootEntities = new bytes32[](lootCount);
    for (uint256 i; i < lootCount; i++) {
      lootEntities[i] = randomEquipmentSystem.mintRandomEquipmentEntity(lootIlvl, randomness);
      LibLootOwner.setSimpleOwnership(lootEntities[i], cycleEntity);
    }

    CombatRewardLogOffchain.set(
      combatEntity,
      CombatRewardLogOffchainData({ requestId: requestId, exp: exp, lootEntities: lootEntities })
    );
  }

  function cancelCycleCombatReward(bytes32 cycleEntity, bytes32 requestId) public {
    LibCycle.requireAccess(cycleEntity);

    // Remove the reward without claiming it
    randomnessSystem.removeRequest(cycleEntity, requestId);
  }

  // TODO remove later; sample loot for testing
  function adminMintLoot(bytes32 cycleEntity, uint32 quantity, uint32 ilvl) public {
    LibCycle.requireAccess(cycleEntity);

    for (uint256 i; i < quantity; i++) {
      bytes32 lootEntity = randomEquipmentSystem.mintRandomEquipmentEntity(
        ilvl,
        uint256(keccak256(abi.encodePacked("admintMintLoot", block.number, gasleft(), i)))
      );
      LibLootOwner.setSimpleOwnership(lootEntity, cycleEntity);
    }
  }
}
