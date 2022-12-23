// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { EffectStatmod } from "./EffectPrototypeComponent.sol";
import { Topic, Op, Element } from "../charstat/Topics.sol";

// utils for easier inlining of dynamic EffectStatmod arrays
function effectStatmods() pure returns (EffectStatmod[] memory) {}

function effectStatmods(
  Topic topic0, Op op0, Element element0, uint256 value0
) pure returns (EffectStatmod[] memory result) {
  result = new EffectStatmod[](1);

  result[0].statmodProtoEntity = topic0.toStatmodEntity(op0, element0);
  result[0].value = value0;
}

function effectStatmods(
  Topic topic0, Op op0, Element element0, uint256 value0,
  Topic topic1, Op op1, Element element1, uint256 value1
) pure returns (EffectStatmod[] memory result) {
  result = new EffectStatmod[](2);

  result[0].statmodProtoEntity = topic0.toStatmodEntity(op0, element0);
  result[0].value = value0;

  result[1].statmodProtoEntity = topic1.toStatmodEntity(op1, element1);
  result[1].value = value1;
}

function effectStatmods(
  Topic topic0, Op op0, Element element0, uint256 value0,
  Topic topic1, Op op1, Element element1, uint256 value1,
  Topic topic2, Op op2, Element element2, uint256 value2
) pure returns (EffectStatmod[] memory result) {
  result = new EffectStatmod[](3);

  result[0].statmodProtoEntity = topic0.toStatmodEntity(op0, element0);
  result[0].value = value0;

  result[1].statmodProtoEntity = topic1.toStatmodEntity(op1, element1);
  result[1].value = value1;

  result[2].statmodProtoEntity = topic2.toStatmodEntity(op2, element2);
  result[2].value = value2;
}

function effectStatmods(
  Topic topic0, Op op0, Element element0, uint256 value0,
  Topic topic1, Op op1, Element element1, uint256 value1,
  Topic topic2, Op op2, Element element2, uint256 value2,
  Topic topic3, Op op3, Element element3, uint256 value3
) pure returns (EffectStatmod[] memory result) {
  result = new EffectStatmod[](4);

  result[0].statmodProtoEntity = topic0.toStatmodEntity(op0, element0);
  result[0].value = value0;

  result[1].statmodProtoEntity = topic1.toStatmodEntity(op1, element1);
  result[1].value = value1;

  result[2].statmodProtoEntity = topic2.toStatmodEntity(op2, element2);
  result[2].value = value2;

  result[3].statmodProtoEntity = topic3.toStatmodEntity(op3, element3);
  result[3].value = value3;
}