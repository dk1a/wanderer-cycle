// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import { LibUtils } from "@wanderer-cycle/core/contracts/LibUtils.sol";
import { AppliedModifierScopeComponent, ID as AppliedModifierScopeComponentID } from "./AppliedModifierScopeComponent.sol";
import { AppliedModifierValueComponent, ID as AppliedModifierValueComponentID } from "./AppliedModifierValueComponent.sol";

library LibApplyModifier {
    error LibApplyModifier__EntityAbsent(uint256 entity);
    error LibApplyModifier__IncreaseByZero(uint256 entity);
    error LibApplyModifier__DecreaseByZero(uint256 entity);

    // ========== UTILS ==========

    function getValueComponent(IUint256Component components) internal view returns (AppliedModifierValueComponent) {
        return AppliedModifierValueComponent(getAddressById(components, AppliedModifierValueComponentID));
    }

    function getScopeComponent(IUint256Component components) internal view returns (AppliedModifierScopeComponent) {
        return AppliedModifierScopeComponent(getAddressById(components, AppliedModifierScopeComponentID));
    }

    /*function getScopeEntity(uint256 scope, TBTime memory time) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(scope, time.timeType)));
    }*/

    // ========== READ ==========

    function has(
        IUint256Component components,
        uint256 entity
    ) internal view returns (bool) {
        return getValueComponent(components).has(entity);
    }

    function getValue(
        IUint256Component components,
        uint256 entity
    ) internal view returns (uint256) {
        // TODO revert if absent?
        return getValueComponent(components).getValue(entity);
    }

    function getEntitiesForScope(
        IUint256Component components,
        uint256 scope
    ) internal returns (uint256[] memory) {
        return getScopeComponent(components).getEntitiesWithValue(scope);
    }

    // ========== WRITE ==========

    function increase(
        IUint256Component components,
        uint256 scope,
        uint256 entity,
        uint256 value
    ) internal returns (bool isUpdate) {
        AppliedModifierValueComponent valueComponent = getValueComponent(components);
        AppliedModifierScopeComponent scopeComponent = getScopeComponent(components);

        // zero increase is invalid
        if (value == 0) {
            revert LibApplyModifier__IncreaseByZero(entity);
        }

        // get stored data
        isUpdate = valueComponent.has(entity);
        if (isUpdate) {
            uint256 storedValue = valueComponent.getValue(entity);
            // increase value
            valueComponent.set(entity, storedValue + value);

            // update scope if necessary (this shouldn't normally happen)
            uint256 storedScope = scopeComponent.getValue(entity);
            if (storedScope != scope) {
                scopeComponent.set(entity, scope);
            }
        } else {
            // create value and scope
            getValueComponent(components).set(entity, value);
            getScopeComponent(components).set(entity, scope);
        }
    }

    function decrease(
        IUint256Component components,
        uint256 entity,
        uint256 value
    ) internal returns (bool isRemove) {
        AppliedModifierValueComponent valueComponent = getValueComponent(components);

        // empty value can't be decreased
        if (!valueComponent.has(entity)) {
            revert LibApplyModifier__EntityAbsent(entity);
        }
        // zero decrease is invalid
        if (value == 0) {
            revert LibApplyModifier__DecreaseByZero(entity);
        }

        uint256 storedValue = valueComponent.getValue(entity);
        isRemove = value >= storedValue;
        if (isRemove) {
            // remove
            valueComponent.remove(entity);
            getScopeComponent(components).remove(entity);
        } else {
            // decrease
            valueComponent.set(entity, storedValue - value);
        }
    }
}