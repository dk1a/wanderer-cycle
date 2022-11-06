// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { OwnableInternal } from '@solidstate/contracts/access/ownable/OwnableInternal.sol';
import { ModifierStorage, ModifierDataFull } from './ModifierStorage.sol';
import { StructUtils } from '../../utils/StructUtils.sol';

contract Modifier is OwnableInternal {
    // modifiers are not enumerable in storage, use events
    event AddModifier(bytes4 id);

    /**
     * @dev Adds new modifiers
     */
    function addModifiers(
        ModifierDataFull[] calldata _modifiers
    ) external onlyOwner {
        for (uint256 i; i < _modifiers.length; i++) {
            require(
                bytes(_modifiers[i].name).length > 2,
                'Modifier: name is too short'
            );
            require(
                bytes(_modifiers[i].topic).length > 2,
                'Modifier: topic is too short'
            );
            bytes4 id = StructUtils.idFromName(_modifiers[i].name);

            ModifierStorage.setModifierData(id, _modifiers[i]);

            emit AddModifier(id);
        }
    }

    /**
     * @dev returns modifier data for given valid id, does no existence check
     * @param id modifier id (see idFromName)
     */
    function getModifier(bytes4 id) external view returns (ModifierDataFull memory) {
        return ModifierStorage.modifierDataFull(id);
    }

    struct ModifierDataIO {
        bytes4 id;
        ModifierDataFull modifierData;
    }

    /**
     * @dev returns all modifier data for off-chain use
     */
    function getModifiers(bytes4[] calldata ids) external view returns (ModifierDataIO[] memory result) {
        result = new ModifierDataIO[](ids.length);
        for (uint256 i; i < ids.length; i++) {
            result[i].id = ids[i];
            result[i].modifierData = ModifierStorage.modifierDataFull(ids[i]);
        }
    }
}