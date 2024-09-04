// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { ActiveCycle } from "../codegen/index.sol";

import { LibCycleTurns } from "./LibCycleTurns.sol";
import { ERC721Namespaces } from "../token/ERC721Namespaces.sol";

/// @title Claim accumulated cycle turns.
/// @dev Does nothing if claimable turns == 0.
contract ClaimCycleTurnsSystem is System {
  function claimCycleTurns(bytes32 wandererEntity) public {
    // check permission
    ERC721Namespaces.WandererNFT.requireOwner(msg.sender, wandererEntity);
    // get cycle entity
    bytes32 cycleEntity = ActiveCycle.get(wandererEntity);
    // claim
    LibCycleTurns.claimTurns(cycleEntity);
  }
}
