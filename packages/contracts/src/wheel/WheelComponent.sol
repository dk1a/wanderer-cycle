// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.Wheel"));

struct WheelData {
  uint32 totalIdentityRequired;
  uint32 charges;
  bool isIsolated;
}

contract WheelComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](3);
    values = new LibTypes.SchemaValue[](3);

    keys[0] = "totalIdentityRequired";
    values[0] = LibTypes.SchemaValue.UINT32;

    keys[1] = "charges";
    values[1] = LibTypes.SchemaValue.UINT32;

    keys[2] = "isIsolated";
    values[2] = LibTypes.SchemaValue.BOOL;
  }

  function set(uint256 entity, WheelData memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (WheelData memory) {
    return abi.decode(getRawValue(entity), (WheelData));
  }
}
