// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.EffectPrototype"));

enum EffectRemovability {
  BUFF,
  DEBUFF,
  PERSISTENT
}

struct EffectStatmod {
  uint256 statmodProtoEntity;
  uint256 value;
}

struct EffectPrototype {
  EffectRemovability removability;
  EffectStatmod[] statmods;
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
  keys = new string[](2);
  values = new LibTypes.SchemaValue[](2);

  keys[0] = "removability";
  values[0] = LibTypes.SchemaValue.UINT8;

  // TODO what about struct arrays?
  keys[1] = "statmods";
  values[1] = LibTypes.SchemaValue.BYTES_ARRAY;
}