// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IComponent } from "solecs/interfaces/IComponent.sol";
import { getAddressById } from "solecs/utils.sol";
import { ScopeComponent } from "./ScopeComponent.sol";

struct SVComponents {
    ScopeComponent scope;
    IComponent value;
}

function getSVComponents(
    IUint256Component components,
    uint256 scopeComponentID,
    uint256 valueComponentID
) view returns (SVComponents memory) {
    return SVComponents({
        scope: ScopeComponent(getAddressById(components, scopeComponentID)),
        value: IComponent(getAddressById(components, valueComponentID))
    });
}

library LibScopedValue {
    error LibScopedValue__EntityAbsent(uint256 entity);
    error LibScopedValue__ScopeEntityMismatch(uint256 entity, uint256 scopeEntity);

    /**
     * @dev Has entity?
     */
    function has(
        SVComponents memory _svc,
        uint256 entity
    ) internal view returns (bool) {
        return _svc.value.has(entity);
    }

    /**
     * @dev Get value
     */
    function get(
        SVComponents memory _svc,
        uint256 entity
    ) internal view returns (bytes memory) {
        if (!_svc.value.has(entity)) {
            revert LibScopedValue__EntityAbsent(entity);
        }
        // get
        return _svc.value.getValue(entity);
    }

    /**
     * @dev Create value if it's absent, otherwise return storedValue so it can be updated
     * @return storedValue empty bytes if created, raw value otherwise
     */
    function getOrCreate(
        SVComponents memory _svc,
        uint256 scopeEntity,
        uint256 entity,
        bytes memory value
    ) internal returns (bytes memory storedValue) {
        bool hasValue = _svc.value.has(entity);
        if (hasValue) {
            // TODO a flag to allow this?
            if (_svc.scope.getValue(entity) != scopeEntity) {
                revert LibScopedValue__ScopeEntityMismatch(entity);
            }
            // get
            storedValue = _svc.value.getRawValue(entity);
        } else {
            // set
            _svc.scope.set(entity, scopeEntity);
            _svc.value.set(entity, value);
        }
    }

    /**
     * @dev Set value
     */
    /*function set(
        SVComponents memory _svc,
        uint256 scopeEntity,
        uint256 entity,
        bytes memory value
    ) internal {
        _svc.scope.set(entity, scopeEntity);
        _svc.value.set(entity, value);
    }*/

    /**
     * @dev Updates value component only
     */
    function updateValue(
        SVComponents memory _svc,
        uint256 entity,
        bytes memory value
    ) internal {
        // TODO this check may be excessive
        if (!_svc.value.has(entity)) {
            revert LibScopedValue__EntityAbsent(entity);
        }
        _svc.value.set(entity, value);
    }

    /**
     * @dev Remove entity
     */
    function remove(
        SVComponents memory _svc,
        uint256 entity
    ) internal {
        if (!_svc.value.has(entity)) {
            revert LibScopedValue__EntityAbsent(entity);
        }
        // remove
        _svc.scope.remove(entity);
        _svc.value.remove(entity);
    }

    /**
     * @dev Get all entities for given scopeEntity
     */
    function getEntitiesForScope(
        SVComponents memory _svc,
        uint256 scopeEntity
    ) internal view returns (uint256[] memory entities) {
        entities = _svc.scope.getEntitiesWithValue(scopeEntity);
    }

    /**
     * @dev Get all entity values for given scopeEntity
     */
    function getValuesForScope(
        SVComponents memory _svc,
        uint256 scopeEntity
    ) internal view returns (bytes[] memory values) {
        uint256[] memory entities = getEntitiesForScope(_svc, scopeEntity);
        values = new bytes[](entities.length);
        for (uint256 i; i < entities.length; i++) {
            values[i] = _svc.value.getRawValue(entities[i]);
        }
    }
}