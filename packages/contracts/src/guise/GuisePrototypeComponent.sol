// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

import { PS_L } from "../charstat/ExperienceComponent.sol";

uint256 constant ID = uint256(keccak256("component.GuisePrototype"));

struct GuisePrototype {
  uint32[PS_L] gainMul;
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
    keys = new string[](3);
    values = new LibTypes.SchemaValue[](3);

    // TODO this
  }

  function set(uint256 entity, GuisePrototype memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (GuisePrototype memory) {
    return abi.decode(getRawValue(entity), (GuisePrototype));
  }
}

