// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// imports for the component
import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

// imports for `executeSystemCallback` helper
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { ISystem } from "solecs/interfaces/ISystem.sol";
import { getAddressById } from "solecs/utils.sol";

import { SystemCallback, executeSystemCallback } from "std-contracts/components/SystemCallbackBareComponent.sol";

uint256 constant ID = uint256(keccak256("component.DurationOnEnd"));

contract DurationOnEndComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](2);
    values = new LibTypes.SchemaValue[](2);

    keys[0] = "systemId";
    values[0] = LibTypes.SchemaValue.UINT256;

    keys[1] = "args";
    values[1] = LibTypes.SchemaValue.BYTES;
  }

  function set(uint256 entity, SystemCallback memory value) public virtual {
    set(entity, abi.encode(value.systemId, value.args));
  }

  function getValue(uint256 entity) public view virtual returns (SystemCallback memory) {
    (uint256 systemId, bytes memory args) = abi.decode(getRawValue(entity), (uint256, bytes));
    return SystemCallback(systemId, args);
  }
}
