// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { StatmodOp, EleStat } from "./codegen/common.sol";

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
