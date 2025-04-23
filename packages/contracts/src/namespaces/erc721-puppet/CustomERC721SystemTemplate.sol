// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ERC721System } from "@latticexyz/world-modules/src/modules/erc721-puppet/ERC721System.sol";

import { uriSystem } from "../uri/codegen/systems/UriSystemLib.sol";

// It's called SystemTemplate because it shouldn't be deployed or otherwise detected by mud automatically
contract CustomERC721SystemTemplate is ERC721System {
  /**
   * @dev See {IERC721Metadata-tokenURI}.
   */
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    return uriSystem.entityURI(bytes32(tokenId));
  }
}
