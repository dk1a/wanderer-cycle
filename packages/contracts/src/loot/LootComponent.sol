// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "@latticexyz/solecs/src/LibTypes.sol";
import { Component } from "@latticexyz/solecs/src/Component.sol";

import { AffixPartId } from "../affix/LibPickAffixes.sol";

uint256 constant ID = uint256(keccak256("component.Loot"));

struct Loot {
  uint256 ilvl;
  AffixPartId[] affixPartIds;
  uint256[] affixProtoEntities;
  uint256[] affixValues;
}

contract LootComponent is Component {
  constructor(address world) Component(world, ID) {}
  
  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](3);
    values = new LibTypes.SchemaValue[](4);

    keys[0] = "ilvl";
    values[0] = LibTypes.SchemaValue.UINT256;

    // TODO I don't really like this enum array
    keys[1] = "affixPartIds";
    values[1] = LibTypes.SchemaValue.UINT8_ARRAY;

    keys[2] = "affixProtoEntities";
    values[2] = LibTypes.SchemaValue.UINT256_ARRAY;

    keys[3] = "affixValues";
    values[3] = LibTypes.SchemaValue.UINT256_ARRAY;
  }

  function set(uint256 entity, Loot memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (Loot memory) {
    return abi.decode(getRawValue(entity), (Loot));
  }

  function getEntitiesWithValue(Loot memory value) public view returns (uint256[] memory) {
    return getEntitiesWithValue(abi.encode(value));
  }
}