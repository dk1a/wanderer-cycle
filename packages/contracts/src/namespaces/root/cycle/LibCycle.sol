// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { ActiveGuise } from "../codegen/tables/ActiveGuise.sol";
import { GuisePrototype } from "../codegen/tables/GuisePrototype.sol";
import { ActiveCycle } from "../codegen/tables/ActiveCycle.sol";
import { CycleOwner } from "../codegen/tables/CycleOwner.sol";
import { CycleMetadata } from "../codegen/tables/CycleMetadata.sol";

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibExperience } from "../charstat/LibExperience.sol";
import { LibSpawnEquipmentSlots } from "../equipment/LibSpawnEquipmentSlots.sol";
import { LibWheel } from "../../wheel/LibWheel.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibLearnedSkills } from "../skill/LibLearnedSkills.sol";
import { ERC721Namespaces } from "../token/ERC721Namespaces.sol";

library LibCycle {
  error LibCycle_DuplicateActiveCycle();
  error LibCycle_CycleNotActive(bytes32 cycleEntity);
  error LibCycle_InvalidGuiseEntity();

  function initCycle(
    bytes32 wandererEntity,
    bytes32 guiseEntity,
    bytes32 wheelEntity
  ) internal returns (bytes32 cycleEntity) {
    // cycleEntity is for all the in-cycle components (everything except activeCycle)
    cycleEntity = getUniqueEntity();
    // Cycle must be inactive
    if (ActiveCycle.get(wandererEntity) != bytes32(0)) {
      revert LibCycle_DuplicateActiveCycle();
    }
    // Prototypes must exist
    uint32[3] memory guiseProto = GuisePrototype.get(guiseEntity);
    if (guiseProto[0] == 0 && guiseProto[1] == 0 && guiseProto[2] == 0) {
      revert LibCycle_InvalidGuiseEntity();
    }

    LibWheel.activateWheel(wandererEntity, cycleEntity, wheelEntity);

    LibCycleInternalPart2.initCyclePart2(wandererEntity, cycleEntity, guiseEntity);

    return cycleEntity;
  }

  /**
   * @dev End the cycle, which will not count as completed, and provides no rewards
   */
  function cancelCycle(bytes32 cycleEntity) internal {
    bytes32 wandererEntity = requireActiveCycle(cycleEntity);
    // Clear the current cycle
    ActiveCycle.deleteRecord(wandererEntity);
    // Update cycle metadata
    CycleMetadata.setEndTime(cycleEntity, block.timestamp);
  }

  /**
   * @dev End the cycle with completion rewards
   */
  function completeCycle(bytes32 cycleEntity) internal {
    bytes32 wandererEntity = requireActiveCycle(cycleEntity);
    // Clear the current cycle
    ActiveCycle.deleteRecord(wandererEntity);
    // Update cycle metadata
    CycleMetadata.setEndTime(cycleEntity, block.timestamp);
    // Complete the wheel of the cycle and get rewards
    LibWheel.completeWheel(wandererEntity, cycleEntity);
  }

  /**
   * @notice Check that the cycle has an owner, and is the owner's active cycle
   * @return wandererEntity cycle owner
   */
  function requireActiveCycle(bytes32 cycleEntity) internal view returns (bytes32 wandererEntity) {
    wandererEntity = CycleOwner.get(cycleEntity);
    bytes32 activeCycleEntity = ActiveCycle.get(wandererEntity);
    if (cycleEntity != activeCycleEntity) {
      revert LibCycle_CycleNotActive(cycleEntity);
    }
  }

  /**
   * @notice Check that _msgSender has access to cycleEntity's owner
   */
  function requireAccess(bytes32 cycleEntity) internal view {
    bytes32 ownerEntity = CycleOwner.get(cycleEntity);
    // _msgSender must own the NFT that owns the cycle
    ERC721Namespaces.WandererNFT.requireOwner(WorldContextConsumerLib._msgSender(), ownerEntity);
    // TODO should this also include requireActiveCycle?
  }
}

// This is separate and public only to split codesize
library LibCycleInternalPart2 {
  function initCyclePart2(bytes32 wandererEntity, bytes32 cycleEntity, bytes32 guiseEntity) public {
    // Set active cycle and its owner
    ActiveCycle.set(wandererEntity, cycleEntity);
    CycleOwner.set(cycleEntity, wandererEntity);
    // Set cycle metadata
    CycleMetadata.setStartTime(cycleEntity, block.timestamp);
    // Set active guise
    ActiveGuise.set(cycleEntity, guiseEntity);
    // Init exp
    LibExperience.initExp(cycleEntity);
    // Init currents
    LibCharstat.setFullCurrents(cycleEntity);
    // Claim initial cycle turns
    LibCycleTurns.claimTurns(cycleEntity);
    // Spawn equipment slots
    LibSpawnEquipmentSlots.spawnEquipmentSlots(cycleEntity);
    // Copy permanent skills
    LibLearnedSkills.copySkills(wandererEntity, cycleEntity);
  }
}
