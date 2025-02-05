// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { ActiveCycle, GenericDurationData } from "../codegen/index.sol";
import { Duration } from "../modules/duration/Duration.sol";

import { LibCycle } from "./LibCycle.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibActiveCombat } from "../combat/LibActiveCombat.sol";

contract PassCycleTurnSystem is System {
  function passCycleTurn(bytes32 wandererEntity) public {
    // reverts if sender doesn't have permission
    bytes32 cycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);
    // not available during combat (since it fully heals)
    LibActiveCombat.requireNotActiveCombat(cycleEntity);

    // subtract 1 turn
    LibCycleTurns.decreaseTurns(cycleEntity, 1);
    Duration.decreaseApplications(
      ActiveCycle._tableId,
      cycleEntity,
      GenericDurationData({ timeId: keccak256("turn"), timeValue: 1 })
    );
    // fill up currents
    LibCharstat.setFullCurrents(cycleEntity);
  }
}
