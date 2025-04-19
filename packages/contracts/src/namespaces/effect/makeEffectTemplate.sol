// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { EffectTemplateData } from "./codegen/index.sol";
import { StatmodOp, EleStat } from "../../codegen/common.sol";
import { StatmodTopic } from "../statmod/StatmodTopic.sol";

// utils to make hardcoded `EffectTemplateData` structs with less hassle and visual overhead

function makeEffectTemplate() pure returns (EffectTemplateData memory result) {}

function makeEffectTemplate(
  StatmodTopic topic0,
  StatmodOp op0,
  EleStat element0,
  uint32 value0
) pure returns (EffectTemplateData memory result) {
  result.statmodEntities = new bytes32[](1);
  result.statmodEntities[0] = topic0.toStatmodEntity(op0, element0);

  result.values = new uint32[](1);
  result.values[0] = value0;
}

function makeEffectTemplate(
  StatmodTopic topic0,
  StatmodOp op0,
  EleStat element0,
  uint32 value0,
  StatmodTopic topic1,
  StatmodOp op1,
  EleStat element1,
  uint32 value1
) pure returns (EffectTemplateData memory result) {
  result.statmodEntities = new bytes32[](2);
  result.statmodEntities[0] = topic0.toStatmodEntity(op0, element0);
  result.statmodEntities[1] = topic1.toStatmodEntity(op1, element1);

  result.values = new uint32[](2);
  result.values[0] = value0;
  result.values[1] = value1;
}
