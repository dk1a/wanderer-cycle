// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { EffectRemovability, EffectPrototype } from "./EffectPrototypeComponent.sol";
import { Topic, Op, Element } from "../charstat/Topics.sol";

// utils to make hardcoded `EffectPrototype` structs with less hassle and visual overhead

function makeEffectPrototype() pure returns (EffectPrototype memory result) {}

function makeEffectPrototype(
  EffectRemovability removability,
  Topic topic0, Op op0, Element element0, uint32 value0
) pure returns (EffectPrototype memory result) {
  result.removability = removability;

  result.statmodProtoEntities = new uint256[](1);
  result.statmodProtoEntities[0] = topic0.toStatmodEntity(op0, element0);

  result.statmodValues = new uint32[](1);
  result.statmodValues[0] = value0;
}

function makeEffectPrototype(
  EffectRemovability removability,
  Topic topic0, Op op0, Element element0, uint32 value0,
  Topic topic1, Op op1, Element element1, uint32 value1
) pure returns (EffectPrototype memory result) {
  result.removability = removability;

  result.statmodProtoEntities = new uint256[](2);
  result.statmodProtoEntities[0] = topic0.toStatmodEntity(op0, element0);
  result.statmodProtoEntities[1] = topic1.toStatmodEntity(op1, element1);

  result.statmodValues = new uint32[](2);
  result.statmodValues[0] = value0;
  result.statmodValues[1] = value1;
}

function makeEffectPrototype(
  EffectRemovability removability,
  Topic topic0, Op op0, Element element0, uint32 value0,
  Topic topic1, Op op1, Element element1, uint32 value1,
  Topic topic2, Op op2, Element element2, uint32 value2
) pure returns (EffectPrototype memory result) {
  result.removability = removability;

  result.statmodProtoEntities = new uint256[](3);
  result.statmodProtoEntities[0] = topic0.toStatmodEntity(op0, element0);
  result.statmodProtoEntities[1] = topic1.toStatmodEntity(op1, element1);
  result.statmodProtoEntities[2] = topic2.toStatmodEntity(op2, element2);

  result.statmodValues = new uint32[](3);
  result.statmodValues[0] = value0;
  result.statmodValues[1] = value1;
  result.statmodValues[2] = value2;
}

function makeEffectPrototype(
  EffectRemovability removability,
  Topic topic0, Op op0, Element element0, uint32 value0,
  Topic topic1, Op op1, Element element1, uint32 value1,
  Topic topic2, Op op2, Element element2, uint32 value2,
  Topic topic3, Op op3, Element element3, uint32 value3
) pure returns (EffectPrototype memory result) {
  result.removability = removability;

  result.statmodProtoEntities = new uint256[](4);
  result.statmodProtoEntities[0] = topic0.toStatmodEntity(op0, element0);
  result.statmodProtoEntities[1] = topic1.toStatmodEntity(op1, element1);
  result.statmodProtoEntities[2] = topic2.toStatmodEntity(op2, element2);
  result.statmodProtoEntities[3] = topic3.toStatmodEntity(op3, element3);

  result.statmodValues = new uint32[](4);
  result.statmodValues[0] = value0;
  result.statmodValues[1] = value1;
  result.statmodValues[2] = value2;
  result.statmodValues[3] = value3;
}