// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { EffectStatmod } from "./EffectPrototypeComponent.sol";

// utils for easier inlining of dynamic EffectStatmod arrays
function _effectStatmods() pure returns (EffectStatmod[] memory) {}

function _effectStatmods(
  bytes memory name0, uint256 value0
) pure returns (EffectStatmod[] memory result) {
  result = new EffectStatmod[](1);

  result[0].statmodProtoEntity = uint256(keccak256(name0));
  result[0].value = value0;
}

function _effectStatmods(
  bytes memory name0, uint256 value0,
  bytes memory name1, uint256 value1
) pure returns (EffectStatmod[] memory result) {
  result = new EffectStatmod[](2);

  result[0].statmodProtoEntity = uint256(keccak256(name0));
  result[0].value = value0;

  result[1].statmodProtoEntity = uint256(keccak256(name1));
  result[1].value = value1;
}

function _effectStatmods(
  bytes memory name0, uint256 value0,
  bytes memory name1, uint256 value1,
  bytes memory name2, uint256 value2
) pure returns (EffectStatmod[] memory result) {
  result = new EffectStatmod[](3);

  result[0].statmodProtoEntity = uint256(keccak256(name0));
  result[0].value = value0;

  result[1].statmodProtoEntity = uint256(keccak256(name1));
  result[1].value = value1;

  result[2].statmodProtoEntity = uint256(keccak256(name2));
  result[2].value = value2;
}

function _effectStatmods(
  bytes memory name0, uint256 value0,
  bytes memory name1, uint256 value1,
  bytes memory name2, uint256 value2,
  bytes memory name3, uint256 value3
) pure returns (EffectStatmod[] memory result) {
  result = new EffectStatmod[](4);

  result[0].statmodProtoEntity = uint256(keccak256(name0));
  result[0].value = value0;

  result[1].statmodProtoEntity = uint256(keccak256(name1));
  result[1].value = value1;

  result[2].statmodProtoEntity = uint256(keccak256(name2));
  result[2].value = value2;

  result[3].statmodProtoEntity = uint256(keccak256(name3));
  result[3].value = value3;
}