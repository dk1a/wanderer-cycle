// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { SmartObjectFramework } from "../evefrontier/SmartObjectFramework.sol";

import { CombatAction, CombatActorOpts, CombatActor } from "../../CustomTypes.sol";
import { GenericDurationData } from "../duration/Duration.sol";
import { CombatActionType, CombatResult } from "../../codegen/common.sol";

interface IWLocationSmartObject is IERC165 {
  function canEnter(bytes32 entrantEntity) external view returns (bool);
  function canAccessPart(bytes32 partEntity, bytes32 entrantEntity) external view returns (bool);
  function getPartDetails(
    bytes32 partEntity,
    bytes32 entrantEntity
  ) external view returns (bool isCombat, bytes32 opponentEntity, string memory description);

  function onEnter(bytes32 entrantEntity) external;
  function onExit(bytes32 entrantEntity) external;
  function onAccessPartCommit(bytes32 partEntity, bytes32 entrantEntity) external;
  function onAccessPartReveal(bytes32 partEntity, bytes32 entrantEntity) external;
  function onFinishPartCommit(bytes32 partEntity, bytes32 entrantEntity) external;
  function onFinishPartReveal(bytes32 partEntity, bytes32 entrantEntity) external;
}
