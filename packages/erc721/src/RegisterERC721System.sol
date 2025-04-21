// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";

import { createPuppet } from "@latticexyz/world-modules/src/modules/puppet/createPuppet.sol";

import { ERC721Registry } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/ERC721Registry.sol";

import { Balances } from "@latticexyz/world-modules/src/modules/tokens/tables/Balances.sol";

import { OperatorApproval } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/OperatorApproval.sol";
import { Owners } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/Owners.sol";
import { TokenApproval } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/TokenApproval.sol";
import { TokenURI } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/TokenURI.sol";
import { ERC721Metadata, ERC721MetadataData } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/ERC721Metadata.sol";

import { ERC721_REGISTRY_TABLE_ID } from "@latticexyz/world-modules/src/modules/erc721-puppet/constants.sol";
import { _erc721SystemId, _balancesTableId, _metadataTableId, _tokenUriTableId, _operatorApprovalTableId, _ownersTableId, _tokenApprovalTableId } from "@latticexyz/world-modules/src/modules/erc721-puppet/utils.sol";
import { ERC721System } from "@latticexyz/world-modules/src/modules/erc721-puppet/ERC721System.sol";

contract RegisterERC721System is System {
  function registerERC721(bytes14 namespace, ERC721MetadataData memory metadata) public {
    registerERC721(namespace, metadata, ERC721RegistrationLib.newDefaultERC721System());
  }

  function registerERC721(bytes14 namespace, ERC721MetadataData memory metadata, System erc721System) public {
    // Register the ERC721 tables and system
    IBaseWorld world = IBaseWorld(WorldContextConsumerLib._world());
    ERC721RegistrationLib.register(world, namespace, erc721System);

    // Initialize the Metadata
    ERC721Metadata.set(_metadataTableId(namespace), metadata);

    // Deploy and register the ERC721 puppet
    ResourceId erc721SystemId = _erc721SystemId(namespace);
    address puppet = createPuppet(world, erc721SystemId);

    // Transfer ownership of the namespace to the caller
    ResourceId namespaceId = WorldResourceIdLib.encodeNamespace(namespace);
    world.transferOwnership(namespaceId, _msgSender());

    // Register the ERC721 in the ERC721Registry
    ERC721Registry.set(ERC721_REGISTRY_TABLE_ID, namespaceId, puppet);
  }
}

library ERC721RegistrationLib {
  /**
   * Register systems and tables for a new ERC721 token in a given namespace
   */
  function register(IBaseWorld world, bytes14 namespace, System erc721System) public {
    // Register the namespace if it doesn't exist yet
    ResourceId tokenNamespace = WorldResourceIdLib.encodeNamespace(namespace);
    world.registerNamespace(tokenNamespace);

    // Register the tables
    OperatorApproval.register(_operatorApprovalTableId(namespace));
    Owners.register(_ownersTableId(namespace));
    TokenApproval.register(_tokenApprovalTableId(namespace));
    TokenURI.register(_tokenUriTableId(namespace));
    Balances.register(_balancesTableId(namespace));
    ERC721Metadata.register(_metadataTableId(namespace));

    // Register the ERC721System
    world.registerSystem(_erc721SystemId(namespace), erc721System, true);
  }

  function newDefaultERC721System() public returns (ERC721System) {
    return new ERC721System();
  }
}
