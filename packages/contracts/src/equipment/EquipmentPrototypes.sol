// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ID } from "./EquipmentPrototypeComponent.sol";

library EquipmentPrototypes {
  uint256 constant WEAPON   = uint256(keccak256(abi.encode(ID, 'Weapon')));
  uint256 constant SHIELD   = uint256(keccak256(abi.encode(ID, 'Shield')));
  uint256 constant HAT      = uint256(keccak256(abi.encode(ID, 'Hat')));
  uint256 constant CLOTHING = uint256(keccak256(abi.encode(ID, 'Clothing')));
  uint256 constant GLOVES   = uint256(keccak256(abi.encode(ID, 'Gloves')));
  uint256 constant PANTS    = uint256(keccak256(abi.encode(ID, 'Pants')));
  uint256 constant BOOTS    = uint256(keccak256(abi.encode(ID, 'Boots')));
  uint256 constant AMULET   = uint256(keccak256(abi.encode(ID, 'Amulet')));
  uint256 constant RING     = uint256(keccak256(abi.encode(ID, 'Ring')));
}