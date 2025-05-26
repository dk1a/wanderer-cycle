// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ERC721Namespace } from "erc721-local/src/ERC721Namespace.sol";

library ERC721Namespaces {
  ERC721Namespace constant Wanderer = ERC721Namespace.wrap("nft-wanderer");
  ERC721Namespace constant Loot = ERC721Namespace.wrap("nft-loot");
}
