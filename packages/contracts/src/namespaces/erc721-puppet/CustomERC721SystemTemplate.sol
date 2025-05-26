// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { WorldContextConsumer } from "@latticexyz/world/src/WorldContext.sol";

import { WorldConsumer } from "@latticexyz/world-consumer/src/experimental/WorldConsumer.sol";

import { ERC721System } from "@latticexyz/world-modules/src/modules/erc721-puppet/ERC721System.sol";

import { uriSystem } from "../uri/codegen/systems/UriSystemLib.sol";

// It's called SystemTemplate because it shouldn't be deployed or otherwise detected by mud automatically
contract CustomERC721SystemTemplate is ERC721System, WorldConsumer {
  constructor(IBaseWorld _world) WorldConsumer(_world) {}

  function _msgSender() public view virtual override(WorldContextConsumer, WorldConsumer) returns (address sender) {
    return WorldConsumer._msgSender();
  }

  function _msgValue() public view virtual override(WorldContextConsumer, WorldConsumer) returns (uint256 value) {
    return WorldConsumer._msgValue();
  }

  /**
   * @dev See {IERC721Metadata-tokenURI}.
   */
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    return uriSystem.entityURI(bytes32(tokenId));
  }

  function approve(address to, uint256 tokenId) public virtual override onlyWorld {
    super.approve(to, tokenId);
  }

  function setApprovalForAll(address operator, bool approved) public virtual override onlyWorld {
    super.setApprovalForAll(operator, approved);
  }

  function transferFrom(address from, address to, uint256 tokenId) public virtual override onlyWorld {
    super.transferFrom(from, to, tokenId);
  }

  // TODO refine access control, this system is the base for several tokens, which may be used by different namespaces
  function mint(address to, uint256 tokenId) public virtual override onlyNamespace("") {
    // _requireOwner is replaced with onlyNamespace check
    _mint(to, tokenId);
  }
}
