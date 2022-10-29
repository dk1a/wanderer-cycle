// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { Uint256BareComponent } from "@latticexyz/std-contracts/components/Uint256BareComponent.sol";

uint256 constant ID = uint256(keccak256('component.TBTimeValueComponent'));

contract TBTimeValueComponent is Uint256BareComponent {
    constructor(address world) Uint256BareComponent(world, ID) {}

    /*
    function set(uint256 entity, uint256 value) public {
        set(entity, abi.encode(value));
    }

    function getValue(uint256 entity) public view returns (uint256) {
        uint256 value = abi.decode(getRawValue(entity), (uint256));
        return value;
    }

    function getEntitiesWithValue(uint256 value) public view returns (uint256[] memory) {
        return getEntitiesWithValue(abi.encode(value));
    }
    */
}