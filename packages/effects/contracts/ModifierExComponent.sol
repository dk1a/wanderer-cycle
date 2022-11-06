// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { BareComponent } from "solecs/BareComponent.sol";
import { LibTypes } from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256('component.ModifierEx'));

struct ModifierExData {
    string name;
    string[2] nameSplitForValue;
    string scopeName;
}

contract ModifierExComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
        keys = new string[](3);
        values = new LibTypes.SchemaValue[](3);

        keys[0] = "name";
        values[0] = LibTypes.SchemaValue.STRING;

        keys[1] = "nameSplitForValue";
        values[1] = LibTypes.SchemaValue.STRING_ARRAY;

        keys[2] = "scopeName";
        values[2] = LibTypes.SchemaValue.STRING;
    }

    function set(uint256 entity, ModifierExData memory value) public {
        set(entity, abi.encode(value));
    }

    function getValue(uint256 entity) public view returns (ModifierExData memory) {
        return abi.decode(getRawValue(entity), (ModifierExData));
    }
}