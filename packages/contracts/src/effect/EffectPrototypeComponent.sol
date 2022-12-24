// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "@latticexyz/solecs/src/LibTypes.sol";
import { BareComponent } from "@latticexyz/solecs/src/BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.EffectPrototype"));

enum EffectRemovability {
  BUFF,
  DEBUFF,
  PERSISTENT
}

struct EffectPrototype {
  EffectRemovability removability;
  uint256[] statmodProtoEntities;
  uint256[] statmodValues;
}

contract EffectPrototypeComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    return _getSchema();
  }

  function set(uint256 entity, EffectPrototype memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (EffectPrototype memory) {
    return abi.decode(getRawValue(entity), (EffectPrototype));
  }
}

function _getSchema() pure returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
  keys = new string[](3);
  values = new LibTypes.SchemaValue[](3);

  keys[0] = "removability";
  values[0] = LibTypes.SchemaValue.UINT8;

  keys[1] = "statmodProtoEntities";
  values[1] = LibTypes.SchemaValue.UINT256_ARRAY;

  keys[2] = "statmodValues";
  values[2] = LibTypes.SchemaValue.UINT256_ARRAY;
}