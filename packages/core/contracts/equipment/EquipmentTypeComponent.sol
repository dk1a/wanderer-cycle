// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Uint256BareComponent } from "std-contracts/components/Uint256BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.EquipmentType"));

/**
 * @title Equipment type makes an entity equippable
 * @dev EquipmentSlotToTypesComponent in turn determines which slots an equipment type can use
 */
contract EquipmentTypeComponent is Uint256BareComponent {
  constructor(address world) Uint256BareComponent(world, ID) {}
}