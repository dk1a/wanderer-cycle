// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Uint256BareComponent } from "std-contracts/components/Uint256BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.CycleTurns"));

contract CycleTurnsComponent is Uint256BareComponent {
  constructor(address world) Uint256BareComponent(world, ID) {}

  function getRawValue(uint256 entity) public view virtual override returns (bytes memory rawValue) {
    rawValue = entityToValue[entity];
    // just return 0 for absent entities to avoid unnecessary `has` checks
    if (rawValue.length == 0) {
      return abi.encode(0);
    }
  }
}