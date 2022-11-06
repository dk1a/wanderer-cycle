// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { Component } from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256('component.Modifier'));

enum Op {
    ADD,
    MUL,
    BADD
}
uint256 constant OP_L = 3;

enum Element {
    NONE,
    PHYSICAL,
    FIRE,
    COLD,
    POISON
}
uint256 constant EL_L = 5;

struct ModifierData {
    uint256 scope;
    Op op;
    Element element;
}

contract ModifierRegistryComponent is Component {
    constructor(address world) Component(world, ID) {}

    function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
        keys = new string[](3);
        values = new LibTypes.SchemaValue[](3);

        keys[0] = "scope";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "op";
        values[1] = LibTypes.SchemaValue.UINT8;

        keys[2] = "element";
        values[2] = LibTypes.SchemaValue.UINT8;
    }

    function set(uint256 entity, ModifierData memory value) public {
        set(entity, abi.encode(value));
    }

    function getValue(uint256 entity) public view returns (ModifierData memory) {
        return abi.decode(getRawValue(entity), (ModifierData));
    }
}