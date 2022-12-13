// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";

import { ERC721BaseSystem } from "@dk1a/solecslib/contracts/token/ERC721/ERC721BaseSystem.sol";

uint256 constant ID = uint256(keccak256("system.WNFT"));

uint256 constant ownershipComponentID = uint256(keccak256("components.WNFT.ownership"));
uint256 constant operatorApprovalComponentID = uint256(keccak256("components.WNFT.operatorApproval"));
uint256 constant tokenApprovalComponentID = uint256(keccak256("components.WNFT.tokenApproval"));

contract WNFTSystem is ERC721BaseSystem {
  constructor(IWorld _world, address _components)
    ERC721BaseSystem(_world, _components, ownershipComponentID, operatorApprovalComponentID, tokenApprovalComponentID) {}
}