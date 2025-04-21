// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";

import { ERC721MetadataData } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/ERC721Metadata.sol";
import { ERC721System } from "@latticexyz/world-modules/src/modules/erc721-puppet/ERC721System.sol";

import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";

import { registerERC721System } from "../src/codegen/systems/RegisterERC721SystemLib.sol";
import { ERC721Namespace } from "../src/ERC721Namespace.sol";

contract RegisterERC721Test is MudTest {
  function testRegisterERC721() public {
    registerERC721System.registerERC721(
      bytes14("testnamespace"),
      ERC721MetadataData({ name: "Test", symbol: "T", baseURI: "" }),
      new ERC721System()
    );

    assertEq(ERC721Namespace.wrap("testnamespace").tokenContract().name(), "Test");
  }
}
