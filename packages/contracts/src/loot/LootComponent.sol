// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { Component } from "solecs/Component.sol";

import { AffixPartId } from "../affix/LibPickAffixes.sol";

uint256 constant ID = uint256(keccak256("component.Loot"));

struct Loot {
  uint32 ilvl;
  AffixPartId[] affixPartIds;
  uint256[] affixProtoEntities;
  uint32[] affixValues;
}

contract LootComponent is Component {
  constructor(address world) Component(world, ID) {}
  
  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](4);
    values = new LibTypes.SchemaValue[](4);

    keys[0] = "ilvl";
    values[0] = LibTypes.SchemaValue.UINT32;

    // TODO I don't really like this enum array
    keys[1] = "affixPartIds";
    values[1] = LibTypes.SchemaValue.UINT8_ARRAY;

    keys[2] = "affixProtoEntities";
    values[2] = LibTypes.SchemaValue.UINT256_ARRAY;

    keys[3] = "affixValues";
    values[3] = LibTypes.SchemaValue.UINT32_ARRAY;
  }

  function set(uint256 entity, Loot memory value) public {
    set(entity, _encode(value));
  }

  function getValue(uint256 entity) public view returns (Loot memory) {
    (
      uint32 ilvl,
      AffixPartId[] memory affixPartIds,
      uint256[] memory affixProtoEntities,
      uint32[] memory affixValues
    ) = abi.decode(getRawValue(entity), (uint32, AffixPartId[], uint256[], uint32[]));

    return Loot(
      ilvl,
      affixPartIds,
      affixProtoEntities,
      affixValues
    );
  }

  function getEntitiesWithValue(Loot memory value) public view returns (uint256[] memory) {
    return getEntitiesWithValue(_encode(value));
  }

  function _encode(Loot memory value) internal pure returns (bytes memory) {
    return abi.encode(
      value.ilvl,
      value.affixPartIds,
      value.affixProtoEntities,
      value.affixValues
    );
  }
}