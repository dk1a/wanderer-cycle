// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.AffixPrototype"));

/**
 * @dev affixProtoEntity = hashed(ID, affixName, tier)
 */
function getAffixProtoEntity(string memory name, uint32 tier) pure returns (uint256) {
  return uint256(keccak256(abi.encode(ID, name, tier)));
}

struct AffixPrototype {
  uint32 tier;
  uint256 statmodProtoEntity;
  uint32 requiredIlvl;
  uint32 min;
  uint32 max;
}

contract AffixPrototypeComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](5);
    values = new LibTypes.SchemaValue[](5);

    keys[0] = "tier";
    values[0] = LibTypes.SchemaValue.UINT32;

    keys[1] = "statmodProtoEntity";
    values[1] = LibTypes.SchemaValue.UINT256;

    keys[2] = "requiredIlvl";
    values[2] = LibTypes.SchemaValue.UINT32;

    keys[3] = "min";
    values[3] = LibTypes.SchemaValue.UINT32;

    keys[4] = "max";
    values[4] = LibTypes.SchemaValue.UINT32;
  }

  function set(uint256 entity, AffixPrototype memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (AffixPrototype memory) {
    return abi.decode(getRawValue(entity), (AffixPrototype));
  }
}
