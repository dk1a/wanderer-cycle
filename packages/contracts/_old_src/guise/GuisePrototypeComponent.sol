// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

import { PS_L } from "../charstat/ExperienceComponent.sol";

uint256 constant ID = uint256(keccak256("component.GuisePrototype"));

struct GuisePrototype {
  uint32[PS_L] levelMul;
}

/**
 * @dev Guise protoEntity = hashed(ID, name)
 */
function getGuiseProtoEntity(string memory name) pure returns (uint256) {
  return uint256(keccak256(abi.encode(ID, name)));
}

contract GuisePrototypeComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](PS_L);
    values = new LibTypes.SchemaValue[](PS_L);

    keys[0] = "levelMul_strength";
    values[0] = LibTypes.SchemaValue.UINT32;

    keys[1] = "levelMul_arcana";
    values[1] = LibTypes.SchemaValue.UINT32;

    keys[2] = "levelMul_dexterity";
    values[2] = LibTypes.SchemaValue.UINT32;
  }

  function set(uint256 entity, GuisePrototype memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (GuisePrototype memory) {
    return abi.decode(getRawValue(entity), (GuisePrototype));
  }
}
