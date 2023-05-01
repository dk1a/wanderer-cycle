// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Uint32BareComponent } from "std-contracts/components/Uint32BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.CycleTurns"));

contract CycleTurnsComponent is Uint32BareComponent {
  constructor(address world) Uint32BareComponent(world, ID) {}

  function getRawValue(uint256 entity) public view virtual override returns (bytes memory rawValue) {
    rawValue = entityToValue[entity];
    // just return 0 for absent entities to avoid unnecessary `has` checks
    if (rawValue.length == 0) {
      return abi.encode(0);
    }
  }
}
