// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { IERC721Mintable } from "@latticexyz/world-modules/src/modules/erc721-puppet/IERC721Mintable.sol";
import { ERC721Registry } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/ERC721Registry.sol";
import { _tokenUriTableId, _ownersTableId } from "@latticexyz/world-modules/src/modules/erc721-puppet/utils.sol";
import { Owners } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/Owners.sol";
import { TokenURI } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/TokenURI.sol";
import { ERC721_REGISTRY_TABLE_ID } from "@latticexyz/world-modules/src/modules/erc721-puppet/constants.sol";

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

type ERC721Namespace is bytes14;

using LibERC721 for ERC721Namespace global;

library LibERC721 {
  error LibERC721_MustBeTokenOwner();

  function unwrap(ERC721Namespace namespace) internal pure returns (bytes14) {
    return ERC721Namespace.unwrap(namespace);
  }

  function tokenAddress(ERC721Namespace namespace) internal view returns (address) {
    return ERC721Registry.get(ERC721_REGISTRY_TABLE_ID, WorldResourceIdLib.encodeNamespace(namespace.unwrap()));
  }

  function mint(ERC721Namespace namespace, address to, bytes32 tokenEntity) internal {
    // Entities are globally unique and can also serve as token ids
    uint256 tokenId = uint256(tokenEntity);

    IERC721Mintable erc721 = IERC721Mintable(namespace.tokenAddress());
    erc721.mint(to, tokenId);
  }

  function burn(ERC721Namespace namespace, bytes32 tokenEntity) internal {
    // Token id is also a globally unique entity
    uint256 tokenId = uint256(tokenEntity);

    IERC721Mintable erc721 = IERC721Mintable(namespace.tokenAddress());
    erc721.burn(tokenId);
  }

  function tokenURI(ERC721Namespace namespace, bytes32 tokenEntity) internal view returns (string memory) {
    // Token id is also a globally unique entity
    uint256 tokenId = uint256(tokenEntity);

    string memory uri = TokenURI.get(_tokenUriTableId(namespace.unwrap()), tokenId);
    return uri;
  }

  function ownerOf(ERC721Namespace namespace, bytes32 tokenEntity) internal view returns (address) {
    // Token id is also a globally unique entity
    uint256 tokenId = uint256(tokenEntity);

    address addr = Owners.get(_ownersTableId(namespace.unwrap()), tokenId);
    return addr;
  }

  function requireOwner(ERC721Namespace namespace, address account, bytes32 tokenEntity) internal view {
    if (account != namespace.ownerOf(tokenEntity)) {
      revert LibERC721_MustBeTokenOwner();
    }
  }
}
