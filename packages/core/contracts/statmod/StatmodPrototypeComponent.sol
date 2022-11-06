// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.StatmodPrototype"));

enum Op {
  ADD,
  MUL,
  BADD
}
uint256 constant OP_L = 3;
uint256 constant OP_FINAL = uint256(Op.ADD);

enum Element {
  ALL,
  PHYSICAL,
  FIRE,
  COLD,
  POISON
}
uint256 constant EL_L = 5;

struct StatmodPrototype {
  bytes4 topic;
  Op op;
  Element element;
}

contract StatmodPrototypeComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](3);
    values = new LibTypes.SchemaValue[](3);

    keys[0] = "topic";
    values[0] = LibTypes.SchemaValue.BYTES4;

    keys[1] = "op";
    values[1] = LibTypes.SchemaValue.UINT8;

    keys[2] = "element";
    values[2] = LibTypes.SchemaValue.UINT8;
  }

  function set(uint256 entity, StatmodPrototype memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (StatmodPrototype memory) {
    return abi.decode(getRawValue(entity), (StatmodPrototype));
  }
}

