// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IComponent } from "solecs/interfaces/IComponent.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { ModifierComponent, ID as ModifierComponentID, ModifierData } from "./ModifierComponent.sol";
import { ModifierExComponent, ID as ModifierExComponentID, ModifierExData } from "./ModifierExComponent.sol";

uint256 constant ID = uint256(keccak256("system.Modifier"));

struct ModifierDataIO {
    ModifierData main;
    ModifierExData extended;
}

contract ModifierSystem is System {
    constructor(IWorld _world, address _components) System(_world, _components) {}

    function execute(bytes memory arguments) public returns (bytes memory) {
        (
            ModifierData[] memory modifierData,
            ModifierExData[] memory 
        ) = abi.decode(arguments, (ModifierData[], ModifierExData[]));

        return abi.encode(entity);
    }

    function executeTyped(uint256[][] memory ingredients) public returns (uint256) {
        return abi.decode(execute(abi.encode(ingredients)), (uint256));
    }
}