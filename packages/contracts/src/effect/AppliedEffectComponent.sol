// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "@latticexyz/solecs/src/LibTypes.sol";
import { BareComponent } from "@latticexyz/solecs/src/BareComponent.sol";

import { EffectPrototype, _getSchema } from "./EffectPrototypeComponent.sol";

uint256 constant ID = uint256(keccak256("component.AppliedEffect"));

/**
 * @title Copy of EffectPrototype created during application.
 * @dev If EffectPrototype changes, any applied effects will hold the old value until reapplied
 * (this avoids statmod leaks)
 */
contract AppliedEffectComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    return _getSchema();
  }

  function set(uint256 entity, EffectPrototype memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (EffectPrototype memory) {
    return abi.decode(getRawValue(entity), (EffectPrototype));
  }
}