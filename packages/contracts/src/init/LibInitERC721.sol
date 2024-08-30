// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { IWorld } from "../codegen/world/IWorld.sol";
import { IERC721Mintable } from "@latticexyz/world-modules/src/modules/erc721-puppet/IERC721Mintable.sol";
import { ERC721MetadataData } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/ERC721Metadata.sol";
import { registerERC721 } from "@latticexyz/world-modules/src/modules/erc721-puppet/registerERC721.sol";

import { IWorld } from "../codegen/world/IWorld.sol";
import { ERC721Config } from "../codegen/index.sol";
import { ERC721Namespaces } from "../token/ERC721Namespaces.sol";

library LibInitERC721 {
  function init() internal {
    _register(ERC721Namespaces.WandererNFT.unwrap(), "Wanderer", "WNFT");
  }

  function _register(bytes14 namespace, string memory name, string memory symbol) private {
    IWorld world = IWorld(WorldContextConsumerLib._world());

    ERC721MetadataData memory metadata = ERC721MetadataData({ name: name, symbol: symbol, baseURI: "" });
    IERC721Mintable tokenAddress = registerERC721(world, namespace, metadata);

    // Transfer ownership of the token namespace to the world contract
    // (allows the world to use admin functions like minting)
    world.transferOwnership(WorldResourceIdLib.encodeNamespace(namespace), address(world));

    ERC721Config.set(namespace, address(tokenAddress));
  }
}
