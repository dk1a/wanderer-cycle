// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";
import { getAddressById, addressToEntity } from "@latticexyz/solecs/src/utils.sol";

import { OwnedByComponent, ID as OwnedByComponentID } from "../common/OwnedByComponent.sol";
import { WNFTSubsystem, ID as WNFTSubsystemID } from "../token/WNFTSubsystem.sol";

import { LibToken } from "../token/LibToken.sol";

library LibLootOwner {
  /// @dev Sets OwnedByComponent.
  /// (any entity can be the owner, no default user-facing transfer functions)
  function setSimpleOwnership(
    IUint256Component components,
    uint256 lootEntity,
    uint256 ownerEntity
  ) internal {
    OwnedByComponent ownedByComp = OwnedByComponent(getAddressById(components, OwnedByComponentID));
    ownedByComp.set(lootEntity, ownerEntity);
  }

  /// @dev Mints an ERC721 token with `lootEntity` as the id.
  /// (only an address can be the owner, full ERC721 interface by default)
  function setTradeableOwnership(
    IUint256Component systems,
    uint256 lootEntity,
    address ownerAccount
  ) internal {
    WNFTSubsystem wnftSubsystem = WNFTSubsystem(getAddressById(systems, WNFTSubsystemID));
    wnftSubsystem.executeSafeMint(ownerAccount, lootEntity, '');
  }

  function ownerOf(
    IUint256Component components,
    uint256 lootEntity
  ) internal view returns (uint256) {
    address ownerAccount = LibToken.ownerOf(components, lootEntity);
    if (ownerAccount != address(0)) {
      return addressToEntity(ownerAccount);
    } else {
      OwnedByComponent ownedByComp = OwnedByComponent(getAddressById(components, OwnedByComponentID));
      return ownedByComp.getValue(lootEntity);
    }
  }
}