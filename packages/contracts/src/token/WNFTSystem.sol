// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";

import { ERC721BaseSubsystem } from "@dk1a/solecslib/contracts/token/ERC721/ERC721BaseSubsystem.sol";

uint256 constant ID = uint256(keccak256("system.WNFT"));

uint256 constant ownershipComponentID = uint256(keccak256("component.WNFT_Ownership"));
uint256 constant operatorApprovalComponentID = uint256(keccak256("component.WNFT_OperatorApproval"));
uint256 constant tokenApprovalComponentID = uint256(keccak256("component.WNFT_TokenApproval"));

contract WNFTSystem is ERC721BaseSubsystem {
  constructor(IWorld _world, address _components)
    ERC721BaseSubsystem(_world, _components, ownershipComponentID, operatorApprovalComponentID, tokenApprovalComponentID) {}
}