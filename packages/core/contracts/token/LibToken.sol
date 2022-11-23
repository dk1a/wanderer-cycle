// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IComponent } from "solecs/interfaces/IComponent.sol";
import { getAddressById } from "solecs/utils.sol";

import { OwnershipComponent } from "@dk1a/solecslib/contracts/token/ERC721/components/OwnershipComponent.sol";
import { ownershipComponentID } from "./WNFTSystem.sol";

library LibToken {
  error LibToken_NonExistentToken();
  error LibToken_MustBeTokenOwner();

  function ownerOf(IUint256Component components, uint256 tokenEntity) internal view returns (address) {
    IComponent ownershipComp = IComponent(getAddressById(components, ownershipComponentID));
    bytes memory rawValue = ownershipComp.getRawValue(tokenEntity);
    if (rawValue.length == 0) {
      revert LibToken_NonExistentToken();
    }
    return abi.decode(rawValue, (address));
  }

  function requireOwner(
    IUint256Component components,
    uint256 tokenEntity,
    address account
  ) internal view {
    if (account != ownerOf(components, tokenEntity)) {
      revert LibToken_MustBeTokenOwner();
    }
  }
}