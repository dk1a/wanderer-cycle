// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";

import { ActiveCycle } from "./codegen/tables/ActiveCycle.sol";
import { CycleOwner } from "./codegen/tables/CycleOwner.sol";
import { CycleMetadata } from "./codegen/tables/CycleMetadata.sol";
import { CompletedCycleHistory } from "./codegen/tables/CompletedCycleHistory.sol";

import { wheelSystem } from "../wheel/codegen/systems/WheelSystemLib.sol";

import { ERC721Namespaces } from "../erc721-puppet/ERC721Namespaces.sol";

library LibCycle {
  error LibCycle_CycleNotActive(bytes32 cycleEntity);
  error LibCycle_CycleActive(bytes32 wandererEntity);

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
    wheelSystem.completeWheel(wandererEntity, cycleEntity);
    // Update cycle owner's completion history
    CompletedCycleHistory.push(wandererEntity, cycleEntity);
  }

  /**
   * @notice Check that the cycle has an owner, and is the owner's active cycle
   * @param cycleEntity cycle
   * @return wandererEntity cycle owner
   */
  function requireActiveCycle(bytes32 cycleEntity) internal view returns (bytes32 wandererEntity) {
    wandererEntity = CycleOwner.get(cycleEntity);
    bytes32 activeCycleEntity = ActiveCycle.get(wandererEntity);
    if (cycleEntity != activeCycleEntity || cycleEntity == bytes32(0)) {
      revert LibCycle_CycleNotActive(cycleEntity);
    }
  }

  /**
   * @notice Check that the owner has no active cycle
   * @param wandererEntity cycle owner
   */
  function requireNotActiveCycle(bytes32 wandererEntity) internal view {
    bytes32 activeCycleEntity = ActiveCycle.get(wandererEntity);
    if (activeCycleEntity != bytes32(0) || wandererEntity == bytes32(0)) {
      revert LibCycle_CycleActive(wandererEntity);
    }
  }

  /**
   * @notice Check that _msgSender has access to cycleEntity's owner
   */
  function requireAccess(bytes32 cycleEntity) internal view {
    bytes32 ownerEntity = CycleOwner.get(cycleEntity);
    // _msgSender must be authorized to use the Wanderer NFT that owns the cycle
    uint256 tokenId = uint256(ownerEntity);
    ERC721Namespaces.Wanderer.checkAuthorized(WorldContextConsumerLib._msgSender(), tokenId);
    // TODO should this also include requireActiveCycle?
  }
}
