// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Uint256BareComponent } from "std-contracts/components/Uint256BareComponent.sol";

contract ValueComponent is Uint256BareComponent {
  constructor(address world, uint256 id) Uint256BareComponent(world, id) {}

  // TODO remove?
  /*function getRawValue(uint256 entity) public view virtual override returns (bytes memory value) {
    value = entityToValue[entity];
    if (value.length == 0) {
      return abi.encode(0);
    }
  }*/
}