// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { Uint256BareComponent } from "std-contracts/components/Uint256BareComponent.sol";

uint256 constant ID = uint256(keccak256('component.AppliedModifierValue'));

contract AppliedModifierValueComponent is Uint256BareComponent {
    constructor(address world) Uint256BareComponent(world, ID) {}
}