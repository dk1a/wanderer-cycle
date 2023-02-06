// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { ActiveCycleComponent, ID as ActiveCycleComponentID } from "./ActiveCycleComponent.sol";

import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibToken } from "../token/LibToken.sol";

uint256 constant ID = uint256(keccak256("system.ClaimCycleTurns"));

/// @title Claim accumulated cycle turns.
/// @dev Does nothing if claimable turns == 0.
contract ClaimCycleTurnsSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(uint256 wandererEntity) public {
    execute(abi.encode(wandererEntity));
  }

  function execute(bytes memory args) public override returns (bytes memory) {
    uint256 wandererEntity = abi.decode(args, (uint256));
    // check permission
    LibToken.requireOwner(components, wandererEntity, msg.sender);
    // get cycle entity
    ActiveCycleComponent activeCycleComp = ActiveCycleComponent(getAddressById(components, ActiveCycleComponentID));
    uint256 cycleEntity = activeCycleComp.getValue(wandererEntity);
    // claim
    LibCycleTurns.claimTurns(components, cycleEntity);

    return "";
  }
}
