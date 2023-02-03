// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.RNGPrecommit"));

struct RNGPrecommit {
  uint256 blocknumber;
  bytes data;
}

contract RNGPrecommitComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](2);
    values = new LibTypes.SchemaValue[](2);

    keys[0] = "blocknumber";
    values[0] = LibTypes.SchemaValue.UINT256;

    keys[1] = "data";
    values[1] = LibTypes.SchemaValue.BYTES;
  }

  function set(uint256 entity, RNGPrecommit memory value) public {
    set(entity, abi.encode(
      value.blocknumber,
      value.data
    ));
  }

  function getValue(uint256 entity) public view returns (RNGPrecommit memory) {
    (
      uint256 blocknumber,
      bytes memory data
    ) = abi.decode(getRawValue(entity), (uint256, bytes));

    return RNGPrecommit(
      blocknumber,
      data
    );
  }
}