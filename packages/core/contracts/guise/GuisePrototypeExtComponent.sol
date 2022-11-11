// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.GuisePrototypeExt"));

struct GuisePrototypeExt {
  string name;
}

contract GuisePrototypeExtComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](1);
    values = new LibTypes.SchemaValue[](1);

    keys[0] = "name";
    values[0] = LibTypes.SchemaValue.STRING;
  }

  function set(uint256 entity, GuisePrototypeExt memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (GuisePrototypeExt memory) {
    return abi.decode(getRawValue(entity), (GuisePrototypeExt));
  }
}

