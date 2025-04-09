// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { LibCycle } from "./LibCycle.sol";

/**
 * @title Cancel an active cycle, forfeiting rewards.
 */
contract CancelCycleSystem is System {
  function cancelCycle(bytes32 cycleEntity) public {
    LibCycle.requireAccess(cycleEntity);

    LibCycle.cancelCycle(cycleEntity);
  }
}
