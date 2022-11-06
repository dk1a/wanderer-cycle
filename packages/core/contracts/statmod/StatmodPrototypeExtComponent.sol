// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.StatmodPrototypeExt"));

struct StatmodPrototypeExt {
  string name;
  string[2] nameSplitForValue;
  string topic;
}

contract StatmodPrototypeExtComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](3);
    values = new LibTypes.SchemaValue[](4);

    keys[0] = "name";
    values[0] = LibTypes.SchemaValue.STRING;

    keys[1] = "nameSplit0";
    values[1] = LibTypes.SchemaValue.STRING;

    keys[2] = "nameSplit1";
    values[2] = LibTypes.SchemaValue.STRING;

    keys[3] = "topic";
    values[3] = LibTypes.SchemaValue.STRING;
  }

  function set(uint256 entity, StatmodPrototypeExt memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (StatmodPrototypeExt memory) {
    return abi.decode(getRawValue(entity), (StatmodPrototypeExt));
  }
}

