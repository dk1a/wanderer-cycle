// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";

import { ERC1155BaseSubsystem } from "@dk1a/solecslib/contracts/token/ERC1155/ERC1155BaseSubsystem.sol";

uint256 constant ID = uint256(keccak256("system.WFT"));

uint256 constant balanceComponentID = uint256(keccak256("components.WFT.balance"));
uint256 constant operatorApprovalsComponentID = uint256(keccak256("components.WFT.operatorApprovals"));

contract WFTSubsystem is ERC1155BaseSubsystem {
  constructor(IWorld _world, address _components)
    ERC1155BaseSubsystem(_world, _components, balanceComponentID, operatorApprovalsComponentID) {}
}