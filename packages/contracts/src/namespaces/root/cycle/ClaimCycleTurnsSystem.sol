// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { LibCycle } from "./LibCycle.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";

/// @title Claim accumulated cycle turns.
/// @dev Does nothing if claimable turns == 0.
contract ClaimCycleTurnsSystem is System {
  function claimCycleTurns(bytes32 wandererEntity) public {
    // reverts if sender doesn't have permission
    bytes32 cycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);
    // claim
    LibCycleTurns.claimTurns(cycleEntity);
  }
}
