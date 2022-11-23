// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";

import { ERC1155BaseSystem } from "@dk1a/solecslib/contracts/token/ERC1155/ERC1155BaseSystem.sol";

uint256 constant ID = uint256(keccak256("system.WFT"));

uint256 constant balanceComponentID = uint256(keccak256("components.WFT.balance"));
uint256 constant operatorApprovalsComponentID = uint256(keccak256("components.WFT.operatorApprovals"));

contract WFTSystem is ERC1155BaseSystem {
  constructor(IWorld _world, address _components)
    ERC1155BaseSystem(_world, _components, balanceComponentID, operatorApprovalsComponentID) {}
}