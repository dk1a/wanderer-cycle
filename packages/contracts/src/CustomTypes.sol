// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { StatmodOp, EleStat, CombatActionType } from "./codegen/common.sol";

import "@latticexyz/world-modules/src/modules/keysintable/KeysInTableModule.sol";

enum PStat {
  STRENGTH,
  ARCANA,
  DEXTERITY
}

uint256 constant PStat_length = 3;

uint256 constant StatmodOp_length = 3;

uint256 constant EleStat_length = 5;

StatmodOp constant StatmodOpFinal = StatmodOp.ADD;

// Result for initiator; it's based on who loses all life first.
// This just indicates how the combat concluded.
enum CombatResult {
  NONE,
  VICTORY,
  DEFEAT
}

struct CombatAction {
  CombatActionType actionType;
  bytes32 actionEntity;
}

struct CombatActorOpts {
  uint32 maxResistance;
}

struct CombatActor {
  bytes32 entity;
  CombatAction[] actions;
  CombatActorOpts opts;
}
