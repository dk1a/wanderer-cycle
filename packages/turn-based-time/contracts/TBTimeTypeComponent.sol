// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { Uint256Component } from "@latticexyz/std-contracts/components/Uint256Component.sol";

uint256 constant ID = uint256(keccak256('component.TBTimeTypeComponent'));

contract TBTimeTypeComponent is Uint256Component {
    constructor(address world) Uint256Component(world, ID) {}

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