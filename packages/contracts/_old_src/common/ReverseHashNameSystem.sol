// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { StrSlice, toSlice } from "@dk1a/solidity-stringutils/src/StrSlice.sol";

import { ReverseHashNameComponent, ID as ReverseHashNameComponentID } from "./ReverseHashNameComponent.sol";

uint256 constant ID = uint256(keccak256("system.ReverseHashName"));

contract ReverseHashNameSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(string memory name) public returns (uint256) {
    return abi.decode(execute(abi.encode(name)), (uint256));
  }

  /**
   * @dev Permissionlessly map a hashed entity to its string name.
   * Reverts on invalid UTF-8.
   * Returns the character count of the name.
   */
  function execute(bytes memory args) public override returns (bytes memory) {
    string memory name = abi.decode(args, (string));

    ReverseHashNameComponent comp = ReverseHashNameComponent(getAddressById(components, ReverseHashNameComponentID));

    // reverts if UTF-8 is invalid
    uint256 charCount = toSlice(name).chars().count();

    uint256 entity = uint256(keccak256(bytes(name)));
    comp.set(entity, name);

    return abi.encode(charCount);
  }
}
