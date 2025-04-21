// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Module } from "@latticexyz/world/src/Module.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { MODULE_NAMESPACE_ID, ERC721_REGISTRY_TABLE_ID } from "@latticexyz/world-modules/src/modules/erc721-puppet/constants.sol";
import { ERC721Registry } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/ERC721Registry.sol";

contract ERC721Module is Module {
  error ERC721Module_InvalidNamespace(bytes14 namespace);

  function install(bytes memory encodedArgs) public override {
    // Require the module to not be installed with these args yet
    requireNotInstalled(__self, encodedArgs);

    // Register the ERC721Registry
    IBaseWorld world = IBaseWorld(_world());
    world.registerNamespace(MODULE_NAMESPACE_ID);
    ERC721Registry.register(ERC721_REGISTRY_TABLE_ID);
  }
}
