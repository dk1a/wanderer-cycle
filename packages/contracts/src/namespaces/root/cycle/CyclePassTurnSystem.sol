// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { Duration, GenericDurationData } from "../../duration/Duration.sol";
import { ActiveCycle } from "../codegen/index.sol";

import { LibCycle } from "./LibCycle.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibActiveCombat } from "../combat/LibActiveCombat.sol";

contract CyclePassTurnSystem is System {
  function passTurn(bytes32 cycleEntity) public {
    LibCycle.requireAccess(cycleEntity);

    // Not available during combat (since it fully heals)
    LibActiveCombat.requireNotActiveCombat(cycleEntity);

    // Subtract 1 turn
    LibCycleTurns.decreaseTurns(cycleEntity, 1);
    Duration.decreaseApplications(
      ActiveCycle._tableId,
      cycleEntity,
      GenericDurationData({ timeId: keccak256("turn"), timeValue: 1 })
    );
    // Fill up currents
    LibCharstat.setFullCurrents(cycleEntity);
  }
}
