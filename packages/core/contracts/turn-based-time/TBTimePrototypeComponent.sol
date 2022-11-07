// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.TBTimePrototype"));

struct TBTimePrototype {
  bytes4 topic;
  bool onEndRemoveEffect;
}

contract TBTimePrototypeComponent is BareComponent {
  error TBTimePrototypeComponent__AbsentEntity();

  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](2);
    values = new LibTypes.SchemaValue[](2);

    keys[0] = "topic";
    values[0] = LibTypes.SchemaValue.BYTES4;

    keys[1] = "onEndRemoveEffect";
    values[1] = LibTypes.SchemaValue.BOOL;
  }

  function set(uint256 entity, TBTimePrototype memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (TBTimePrototype memory) {
    bytes memory rawValue = getRawValue(entity);
    if (rawValue.length == 0) {
      revert TBTimePrototypeComponent__AbsentEntity();
    }
    return abi.decode(rawValue, (TBTimePrototype));
  }
}

