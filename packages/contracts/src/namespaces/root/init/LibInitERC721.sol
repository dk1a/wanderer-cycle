// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { registerERC721System, ERC721MetadataData } from "erc721-local/src/codegen/systems/RegisterERC721SystemLib.sol";

import { IWorld } from "../../../codegen/world/IWorld.sol";

import { ERC721Namespace, ERC721Namespaces } from "../../erc721-puppet/ERC721Namespaces.sol";
import { CustomERC721SystemTemplate } from "../../erc721-puppet/CustomERC721SystemTemplate.sol";

library LibInitERC721 {
  function init() internal {
    _register(ERC721Namespaces.Wanderer, "Wanderer", "WNFT");
    _register(ERC721Namespaces.Loot, "Loot", "WLOOT");
  }

  function _register(ERC721Namespace namespace, string memory name, string memory symbol) private {
    ERC721MetadataData memory metadata = ERC721MetadataData({ name: name, symbol: symbol, baseURI: "" });
    registerERC721System.registerERC721(namespace.unwrap(), metadata, new CustomERC721SystemTemplate());

    // TODO use non-root namespace for tokens? different namespaces for different token types?
    // Transfer ownership of the token namespace to the world contract
    // (allows the world to use admin functions like minting)
    IWorld world = IWorld(WorldContextConsumerLib._world());
    world.transferOwnership(WorldResourceIdLib.encodeNamespace(namespace.unwrap()), address(world));
  }
}
