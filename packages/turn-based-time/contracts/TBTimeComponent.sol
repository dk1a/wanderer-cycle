// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { BareComponent } from "@latticexyz/solecs/BareComponent.sol";

uint256 constant ID = uint256(keccak256('component.TBTimeComponent'));

struct TBTime {
    uint256 timeType;
    uint32 timeValue;
}

contract TBTimeComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
        keys = new string[](3);
        values = new LibTypes.SchemaValue[](3);

        keys[1] = "timeType";
        values[1] = LibTypes.SchemaValue.UINT256;

        keys[2] = "timeValue";
        values[2] = LibTypes.SchemaValue.UINT32;
    }

    function set(uint256 entity, TBTime memory value) public {
        set(entity, abi.encode(value));
    }

    function getValue(uint256 entity) public view returns (TBTime memory) {
        return abi.decode(getRawValue(entity), (TBTime));
    }
}