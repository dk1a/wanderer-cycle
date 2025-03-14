// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ERC721Namespace } from "./LibERC721.sol";

library ERC721Namespaces {
  ERC721Namespace constant WandererNFT = ERC721Namespace.wrap("WandererNFT");
  ERC721Namespace constant LootNFT = ERC721Namespace.wrap("LootNFT");
}
