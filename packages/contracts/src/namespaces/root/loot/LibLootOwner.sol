// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { OwnedBy } from "../codegen/index.sol";

// import { WNFTSystem, ID as WNFSystemID } from "../token/WNFTSystem.sol";
// import { LibToken } from "../token/LibToken.sol";

library LibLootOwner {
  /// @dev Sets OwnedBy.
  /// (any entity can be the owner, no default user-facing transfer functions)
  function setSimpleOwnership(bytes32 lootEntity, bytes32 ownerEntity) internal {
    OwnedBy.set(lootEntity, ownerEntity);
  }

  /// @dev Mints an ERC721 token with `lootEntity` as the id.
  /// (only an address can be the owner, full ERC721 interface by default)
  // function setTradeableOwnership(bytes32 lootEntity, address ownerAccount) internal {
  //   wnftSystem.executeSafeMint(ownerAccount, lootEntity, "");
  // }

  // function ownerOf(bytes32 lootEntity) internal view returns (bytes32) {
  //   address ownerAccount = LibToken.ownerOf(components, lootEntity);
  //   if (ownerAccount != address(0)) {
  //     return addressToEntity(ownerAccount);
  //   } else {
  //     OwnedByComponent ownedByComp = OwnedByComponent(getAddressById(components, OwnedByComponentID));
  //     return ownedByComp.getValue(lootEntity);
  //   }
  // }
}
