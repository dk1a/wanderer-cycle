// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "@latticexyz/solecs/src/LibTypes.sol";
import { BareComponent } from "@latticexyz/solecs/src/BareComponent.sol";

enum PStat {
  STRENGTH,
  ARCANA,
  DEXTERITY
}
uint256 constant PS_L = 3;

uint256 constant ID = uint256(keccak256("component.Experience"));

contract ExperienceComponent is BareComponent {
  constructor(address _world) BareComponent(_world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](PS_L);
    values = new LibTypes.SchemaValue[](PS_L);

    // TODO how should this work?
    for (uint256 i; i < PS_L; i++) {
      keys[i] = "value";
      values[i] = LibTypes.SchemaValue.UINT32;
    }
  }

  function getValue(uint256 entity) public view returns (uint32[PS_L] memory result) {
    return abi.decode(getRawValue(entity), (uint32[3])); /* 3 == PS_L */
  }

  function set(uint256 entity, uint32[PS_L] memory pstats) public {
    set(entity, abi.encode(pstats));
  }
}