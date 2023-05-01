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

struct EffectPrototype {
  EffectRemovability removability;
  uint256[] statmodProtoEntities;
  uint32[] statmodValues;
}

abstract contract AbstractEffectComponent is BareComponent {
  constructor(address world, uint256 id) BareComponent(world, id) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](3);
    values = new LibTypes.SchemaValue[](3);

    keys[0] = "removability";
    values[0] = LibTypes.SchemaValue.UINT8;

    keys[1] = "statmodProtoEntities";
    values[1] = LibTypes.SchemaValue.UINT256_ARRAY;

    keys[2] = "statmodValues";
    values[2] = LibTypes.SchemaValue.UINT32_ARRAY;
  }

  function set(uint256 entity, EffectPrototype memory value) public {
    set(entity, abi.encode(value.removability, value.statmodProtoEntities, value.statmodValues));
  }

  function getValue(uint256 entity) public view returns (EffectPrototype memory) {
    (EffectRemovability removability, uint256[] memory statmodProtoEntities, uint32[] memory statmodValues) = abi
      .decode(getRawValue(entity), (EffectRemovability, uint256[], uint32[]));

    return EffectPrototype(removability, statmodProtoEntities, statmodValues);
  }
}

contract EffectPrototypeComponent is AbstractEffectComponent {
  constructor(address world) AbstractEffectComponent(world, ID) {}
}
