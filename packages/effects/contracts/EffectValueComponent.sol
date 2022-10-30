// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { Uint256BareComponent } from "@latticexyz/std-contracts/components/Uint256BareComponent.sol";

uint256 constant ID = uint256(keccak256('component.EffectValueComponent'));

contract EffectValueComponent is Uint256BareComponent {
    constructor(address world) Uint256BareComponent(world, ID) {}
}