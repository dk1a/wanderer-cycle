// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { commonSystem } from "../common/codegen/systems/CommonSystemLib.sol";
import { OwnedBy } from "../common/codegen/tables/OwnedBy.sol";
import { ERC721Namespaces } from "../erc721-puppet/ERC721Namespaces.sol";

library LibLootOwner {
  /// @dev Sets OwnedBy.
  /// (any entity can be the owner, no default user-facing transfer functions)
  function setSimpleOwnership(bytes32 lootEntity, bytes32 ownerEntity) internal {
    commonSystem.setOwnedBy(lootEntity, ownerEntity);
  }

  /// @dev Mints an ERC721 token with `lootEntity` as the id.
  /// (only an address can be the owner, full ERC721 interface by default)
  function setTradeableOwnership(bytes32 lootEntity, address ownerAccount) internal {
    uint256 tokenId = uint256(lootEntity);
    ERC721Namespaces.Loot.tokenContract().mint(ownerAccount, tokenId);
  }

  function simpleOwnerOf(bytes32 lootEntity) internal view returns (bytes32 ownerEntity) {
    return OwnedBy.get(lootEntity);
  }

  function tradeableOwnerOf(bytes32 lootEntity) internal view returns (address ownerAccount) {
    uint256 tokenId = uint256(lootEntity);
    return ERC721Namespaces.Loot._ownerOf(tokenId);
  }
}
