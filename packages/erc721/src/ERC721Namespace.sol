// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { IERC721Errors } from "@latticexyz/world-modules/src/modules/erc721-puppet/IERC721Errors.sol";
import { IERC721Mintable } from "@latticexyz/world-modules/src/modules/erc721-puppet/IERC721Mintable.sol";
import { _balancesTableId, _operatorApprovalTableId, _ownersTableId, _tokenApprovalTableId } from "@latticexyz/world-modules/src/modules/erc721-puppet/utils.sol";
import { ERC721_REGISTRY_TABLE_ID } from "@latticexyz/world-modules/src/modules/erc721-puppet/constants.sol";

import { ERC721Registry } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/ERC721Registry.sol";

import { Balances } from "@latticexyz/world-modules/src/modules/tokens/tables/Balances.sol";
import { OperatorApproval } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/OperatorApproval.sol";
import { Owners } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/Owners.sol";
import { TokenApproval } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/TokenApproval.sol";

type ERC721Namespace is bytes14;

using ERC721NamespaceLib for ERC721Namespace global;

library ERC721NamespaceInstance {
  error ERC721NamespaceInstance_MustBeTokenOwner();

  function unwrap(ERC721Namespace namespace) internal pure returns (bytes14) {
    return ERC721Namespace.unwrap(namespace);
  }

  // Returns the address of the puppet ERC721 contract
  function tokenAddress(ERC721Namespace namespace) internal view returns (address) {
    return ERC721Registry.get(ERC721_REGISTRY_TABLE_ID, WorldResourceIdLib.encodeNamespace(namespace.unwrap()));
  }

  // Returns the puppet ERC721 contract
  function tokenContract(ERC721Namespace namespace) internal view returns (IERC721Mintable) {
    return IERC721Mintable(namespace.tokenAddress());
  }

  function _balanceOf(ERC721Namespace namespace, address owner) internal view returns (uint256) {
    return Balances.get(_balancesTableId(namespace.unwrap()), account);
  }

  function _ownerOf(ERC721Namespace namespace, uint256 tokenId) internal view returns (address) {
    return Owners.get(_ownersTableId(namespace.unwrap()), tokenId);
  }

  function _getApproved(ERC721Namespace namespace, uint256 tokenId) internal view {
    return TokenApproval.get(_tokenApprovalTableId(namespace.unwrap()), tokenId);
  }

  function _isApprovedForAll(ERC721Namespace namespace, address owner, address operator) internal view returns (bool) {
    return OperatorApproval.get(_operatorApprovalTableId(namespace.unwrap()), owner, operator);
  }

  function _isAuthorized(
    ERC721Namespace namespace,
    address owner,
    address spender,
    uint256 tokenId
  ) internal view returns (bool) {
    return
      spender != address(0) &&
      (owner == spender || namespace._isApprovedForAll(owner, spender) || namespace._getApproved(tokenId) == spender);
  }

  function _checkAuthorized(
    ERC721Namespace namespace,
    address owner,
    address spender,
    uint256 tokenId
  ) internal view virtual {
    if (!_isAuthorized(owner, spender, tokenId)) {
      if (owner == address(0)) {
        revert IERC721Errors.ERC721NonexistentToken(tokenId);
      } else {
        revert IERC721Errors.ERC721InsufficientApproval(spender, tokenId);
      }
    }
  }
}
