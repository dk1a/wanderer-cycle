// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { ActiveCycleComponent, ID as ActiveCycleComponentID } from "./ActiveCycleComponent.sol";
import { DurationSubSystem, ID as DurationSubSystemID, ScopedDuration } from "../duration/DurationSubSystem.sol";

import { LibCycle } from "./LibCycle.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibActiveCombat } from "../combat/LibActiveCombat.sol";

uint256 constant ID = uint256(keccak256("system.PassCycleTurn"));

contract PassCycleTurnSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(uint256 wandererEntity) public {
    execute(abi.encode(wandererEntity));
  }

  function execute(bytes memory args) public override returns (bytes memory) {
    uint256 wandererEntity = abi.decode(args, (uint256));
    // reverts if sender doesn't have permission
    uint256 cycleEntity = LibCycle.getCycleEntityPermissioned(components, wandererEntity);
    // not available during combat (since it fully heals)
    LibActiveCombat.requireNotActiveCombat(components, cycleEntity);

    // subtract 1 turn
    LibCycleTurns.decreaseTurns(components, cycleEntity, 1);
    DurationSubSystem durationSubSystem = DurationSubSystem(getAddressById(world.systems(), DurationSubSystemID));
    durationSubSystem.executeDecreaseScope(
      cycleEntity,
      ScopedDuration({ timeScopeId: uint256(keccak256("turn")), timeValue: 1 })
    );
    // fill up currents
    LibCharstat.Self memory charstat = LibCharstat.__construct(components, cycleEntity);
    LibCharstat.setFullCurrents(charstat);

    return "";
  }
}
