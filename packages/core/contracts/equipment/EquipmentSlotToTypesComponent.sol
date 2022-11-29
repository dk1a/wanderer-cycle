// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Uint256SetComponent } from "../Uint256SetComponent.sol";

uint256 constant ID = uint256(keccak256("component.EquipmentSlotToTypes"));

/**
 * @title Set of equipment types (value) that can be equipped per slot (key)
 */
contract EquipmentSlotToTypesComponent is Uint256SetComponent {
  constructor(address world) Uint256SetComponent(world, ID) {}
}