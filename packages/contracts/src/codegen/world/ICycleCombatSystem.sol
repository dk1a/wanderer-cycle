// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { CombatAction } from "../../CustomTypes.sol";
import { CombatResult } from "../common.sol";

/**
 * @title ICycleCombatSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface ICycleCombatSystem {
  function cycle__processCycleCombatRound(
    bytes32 cycleEntity,
    CombatAction[] memory initiatorActions
  ) external returns (CombatResult result, bytes32 rewardRequestId);
}
