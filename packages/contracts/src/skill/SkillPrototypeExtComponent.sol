// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "@latticexyz/solecs/src/LibTypes.sol";
import { BareComponent } from "@latticexyz/solecs/src/BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.SkillPrototypeExt"));

struct SkillPrototypeExt {
  string name;
  string description;
}

contract SkillPrototypeExtComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](2);
    values = new LibTypes.SchemaValue[](2);

    keys[0] = "name";
    values[0] = LibTypes.SchemaValue.STRING;

    keys[1] = "description";
    values[1] = LibTypes.SchemaValue.STRING;
  }

  function set(uint256 entity, SkillPrototypeExt memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (SkillPrototypeExt memory) {
    return abi.decode(getRawValue(entity), (SkillPrototypeExt));
  }
}