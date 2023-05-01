// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";

import { IERC721Metadata } from "@solidstate/contracts/token/ERC721/metadata/IERC721Metadata.sol";
import { ERC721BaseSubsystem } from "@dk1a/solecslib/contracts/token/ERC721/ERC721BaseSubsystem.sol";

import { LibUri } from "../uri/LibUri.sol";

uint256 constant ID = uint256(keccak256("system.WNFT"));

uint256 constant ownershipComponentID = uint256(keccak256("component.WNFT_Ownership"));
uint256 constant operatorApprovalComponentID = uint256(keccak256("component.WNFT_OperatorApproval"));
uint256 constant tokenApprovalComponentID = uint256(keccak256("component.WNFT_TokenApproval"));

contract WNFTSystem is ERC721BaseSubsystem, IERC721Metadata {
  constructor(
    IWorld _world,
    address _components
  )
    ERC721BaseSubsystem(
      _world,
      _components,
      ownershipComponentID,
      operatorApprovalComponentID,
      tokenApprovalComponentID
    )
  {
    // register interfaces
    // IERC721Metadata
    _setSupportsInterface(type(IERC721Metadata).interfaceId, true);
  }

  /**
   * @notice inheritdoc IERC721Metadata
   */
  function name() external view virtual returns (string memory) {
    return "wanderer-cycle non-fungible tokens";
  }

  /**
   * @notice inheritdoc IERC721Metadata
   */
  function symbol() external view virtual returns (string memory) {
    return "WNFT";
  }

  /**
   * @notice inheritdoc IERC721Metadata
   */
  function tokenURI(uint256 tokenId) external view virtual returns (string memory) {
    // TODO you need an _exists func in solecslib
    address owner = _get_ownerOf(tokenId);
    if (owner == address(0)) revert ERC721Base__NonExistentToken();

    return LibUri.tokenURI(components, tokenId);
  }
}
