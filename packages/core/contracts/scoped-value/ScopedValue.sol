// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import { ScopeComponent } from "./ScopeComponent.sol";
import { ValueComponent } from "./ValueComponent.sol";

/**
 * @title Reusable operations on scope/value component combination
 * @dev Scope is for doing batched increase/decrease without looping through everything.
 * 
 * TODO bad example, do better
 * E.g. a status effect system creates many different effects,
 * scoped by affected character and attribute: {charId, attr}.
 * Now if you need life for character #7, use {7, 'life'} to avoid looping other stuff.
 */
library ScopedValue {
  error ScopedValue__IncreaseByZero();
  error ScopedValue__DecreaseByZero();
  error ScopedValue__EntityAbsent();

  struct Self {
    ScopeComponent scopeC;
    ValueComponent valueC;
  }

  function __construct(
    IUint256Component registry,
    uint256 scopeComponentId,
    uint256 valueComponentId
  ) internal view returns (Self memory) {
    return Self({
      scopeC: ScopeComponent(getAddressById(registry, scopeComponentId)),
      valueC: ValueComponent(getAddressById(registry, valueComponentId))
    });
  }

  // ========== READ ==========

  function has(
    Self memory __self,
    uint256 entity
  ) internal view returns (bool) {
    return __self.scopeC.has(entity);
  }

  function getValue(
    Self memory __self,
    uint256 entity
  ) internal view returns (uint256) {
    return __self.valueC.getValue(entity);
  }

  function getEntities(
    Self memory __self,
    bytes memory scope
  ) internal view returns (uint256[] memory) {
    return __self.scopeC.getEntitiesWithValue(scope);
  }

  function getValuesForEntities(
    Self memory __self,
    uint256[] memory entities
  ) internal view returns (uint256[] memory values) {
    // get values for entities
    values = new uint256[](entities.length);
    for (uint256 i; i < entities.length; i++) {
      values[i] = __self.valueC.getValue(entities[i]);
    }
  }

  // ========== WRITE ==========

  /**
   * @notice Increase value for `entity`; update scope if necessary
   * @return isUpdate true if only updated, false if created
   */
  function increaseEntity(
    Self memory __self,
    bytes memory scope,
    uint256 entity,
    uint256 value
  ) internal returns (bool isUpdate) {
    // zero increase is invalid
    if (value == 0) {
      revert ScopedValue__IncreaseByZero();
    }

    // get stored data
    isUpdate = has(__self, entity);
    if (isUpdate) {
      uint256 storedValue = __self.valueC.getValue(entity);
      _update(__self, scope, entity, storedValue + value);
    } else {
      // set scope and value
      __self.scopeC.set(entity, scope);
      __self.valueC.set(entity, value);
    }
  }

  /**
   * @notice Decrease value for `entity`; update scope if necessary
   * @dev When a value would become <= 0, it is removed instead
   * @return isUpdate true if only updated, false if removed
   */
  function decreaseEntity(
    Self memory __self,
    bytes memory scope,
    uint256 entity,
    uint256 value
  ) internal returns (bool isUpdate) {
    // zero decrease is invalid
    if (value == 0) {
      revert ScopedValue__DecreaseByZero();
    }
    // can't decrease nonexistent value
    if (!has(__self, entity)) {
      revert ScopedValue__EntityAbsent();
    }

    uint256 storedValue = __self.valueC.getValue(entity);
    isUpdate = storedValue > value;
    if (isUpdate) {
      _update(__self, scope, entity, storedValue - value);
    } else {
      removeEntity(__self, entity);
    }
  }

  /**
    * @dev sets new entity values for both increase and decrease
    */
  function _update(
    Self memory __self,
    bytes memory newScope,
    uint256 entity,
    uint256 newValue
  ) private {
    // update scope if necessary
    if (keccak256(newScope) != keccak256(__self.scopeC.getRawValue(entity))) {
      __self.scopeC.set(entity, newScope);
    }
    // decrease value
    __self.valueC.set(entity, newValue);
  }

  /**
   * @notice Within `scope` increase all values
   * 
   * TODO should this return updated values?
   */
  function increaseScope(
    Self memory __self,
    bytes memory scope,
    uint256 value
  ) internal {
    // zero increase is invalid
    if (value == 0) {
      revert ScopedValue__IncreaseByZero();
    }

    uint256[] memory entities = __self.scopeC.getEntitiesWithValue(scope);
    // loop all entities within scope
    for (uint256 i; i < entities.length; i++) {
      uint256 entity = entities[i];
      uint256 storedValue = __self.valueC.getValue(entity);
      // increase
      __self.valueC.set(entity, storedValue + value);
    }
  }

  /**
   * @notice Within `scope` decrease all values
   * @dev When a value would become <= 0, it is removed instead
   * @return removedEntities entities that were removed due to being <= 0
   */
  function decreaseScope(
    Self memory __self,
    bytes memory scope,
    uint256 value
  ) internal returns (uint256[] memory) {
    // zero decrease is invalid
    if (value == 0) {
      revert ScopedValue__DecreaseByZero();
    }

    uint256[] memory entities = __self.scopeC.getEntitiesWithValue(scope);
    // track removed entities
    uint256[] memory removedEntities = new uint256[](entities.length);
    uint256 removedLength;
    // loop all entities within scope
    for (uint256 i; i < entities.length; i++) {
      uint256 entity = entities[i];
      uint256 storedValue = __self.valueC.getValue(entity);

      // if decrease >= stored
      if (value >= storedValue) {
        // remove
        removeEntity(__self, entity);

        removedEntities[removedLength++] = entity;
      } else {
        // decrease
        __self.valueC.set(entity, storedValue - value);
      }
    }

    // return removedEntities with unused space sliced off 
    if (removedEntities.length == removedLength) {
      return removedEntities;
    }
    uint256[] memory removedEntitiesSliced = new uint256[](removedLength);
    for (uint256 i; i < removedLength; i++) {
      removedEntitiesSliced[i] = removedEntities[i];
    }
    return removedEntitiesSliced;
  }

  /**
   * @notice Remove `entity` from value and scope components
   */
  function removeEntity(
    Self memory __self,
    uint256 entity
  ) internal {
    // TODO should this revert if absent?
    __self.valueC.remove(entity);
    __self.scopeC.remove(entity);
  }

  /**
   * @notice Remove all entities within `scope` from value and scope components
   */
  function removeScope(
    Self memory __self,
    bytes memory scope
  ) internal {
    uint256[] memory entities = __self.scopeC.getEntitiesWithValue(scope);
    for (uint256 i; i < entities.length; i++) {
      __self.valueC.remove(entities[i]);
      __self.scopeC.remove(entities[i]);
    }
  }
}