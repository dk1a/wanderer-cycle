// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { LibCycle } from "./LibCycle.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";

/**
 * @title Claim accumulated cycle turns.
 * @dev Does nothing if claimable turns == 0.
 */
contract CycleClaimTurnsSystem is System {
  function claimTurns(bytes32 cycleEntity) public {
    LibCycle.requireAccess(cycleEntity);

    LibCycleTurns.claimTurns(cycleEntity);
  }
}
