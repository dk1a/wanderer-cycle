// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { AbstractComponent } from "./AbstractComponent.sol";

/**
 * The main purpose of SetComponent is hasItem method,
 * which allows to check existence in O(1) instead of reading the whole array.
 *
 * There's also addItem and removeItem, which don't write the whole array
 * (though they still read it all for world value registration).
 */
contract Uint256SetComponent is AbstractComponent {
  error Uint256SetComponent__ItemAbsent();
  error Uint256SetComponent__ItemDuplicate();
  error Uint256SetComponent__NotImplemented();

  mapping(uint256 => uint256[]) internal entityToValue;
  mapping(uint256 => mapping(uint256 => uint256)) internal itemToIndex;

  constructor(address _world, uint256 _id) AbstractComponent(_world, _id) {}

  // TODO override should be here if IComponent gets getSchema
  function getSchema() public pure returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](1);
    values = new LibTypes.SchemaValue[](1);

    keys[0] = "value";
    values[0] = LibTypes.SchemaValue.UINT256_ARRAY;
  }

  /**
   * Avoid in favor of addItem when possible
   */
  function set(uint256 entity, bytes memory value) public override {
    set(entity, abi.decode(value, (uint256[])));
  }

  /**
   * Avoid in favor of addItem when possible
   */
  function set(uint256 entity, uint256[] memory value) public onlyWriter {
    _set(entity, value);
  }

  /**
   * Avoid in favor of removeItem when possible
   */
  function remove(uint256 entity) public override onlyWriter {
    _remove(entity);
  }

  function has(uint256 entity) public view virtual override returns (bool) {
    return entityToValue[entity].length != 0;
  }

  function getRawValue(uint256 entity) public view virtual override returns (bytes memory) {
    return abi.encode(getValue(entity));
  }

  function getValue(uint256 entity) public view virtual returns (uint256[] memory) {
    return entityToValue[entity];
  }

  /**
   * Check if set has `item` in O(1)
   */
  function hasItem(uint256 entity, uint256 item) public view virtual returns (bool) {
    return itemToIndex[entity][item] != 0;
  }

  /**
   * Add an item without writing the whole array
   */
  function addItem(uint256 entity, uint256 item) public onlyWriter {
    _addItem(entity, item);
  }

  /**
   * Remove an item without writing the whole array
   */
  function removeItem(uint256 entity, uint256 item) public onlyWriter {
    _removeItem(entity, item);
  }

  function _set(uint256 entity, uint256[] memory items) internal virtual {
    // remove old indexes from itemToIndex
    uint256[] memory oldItems = entityToValue[entity];
    for (uint256 i; i < oldItems.length; i++) {
      _removeIndex(entity, oldItems[i]);
    }
    // add new indexes to itemToIndex
    for (uint256 i; i < items.length; i++) {
      if (hasItem(entity, items[i])) {
        // set items should be unique
        revert Uint256SetComponent__ItemDuplicate();
      }
      _setIndex(entity, items[i], i);
    }

    entityToValue[entity] = items;

    IWorld(world).registerComponentValueSet(entity, abi.encode(items));
  }

  function _remove(uint256 entity) internal virtual {
    // remove old indexes from itemToIndex
    uint256[] memory oldItems = entityToValue[entity];
    for (uint256 i; i < oldItems.length; i++) {
      _removeIndex(entity, oldItems[i]);
    }

    delete entityToValue[entity];

    IWorld(world).registerComponentValueRemoved(entity);
  }

  /**
   * Add an item without writing the whole array
   */
  function _addItem(uint256 entity, uint256 item) internal virtual {
    if (hasItem(entity, item)) {
      // item is already in set
      return;
    }

    entityToValue[entity].push(item);
    _setIndex(entity, item, entityToValue[entity].length - 1);

    IWorld(world).registerComponentValueSet(entity, abi.encode(entityToValue[entity]));
  }

  /**
   * Remove an item without writing the whole array
   */
  function _removeItem(uint256 entity, uint256 item) internal virtual {
    if (!hasItem(entity, item)) {
      // item is not in set
      return;
    }

    uint256 lastIndex = entityToValue[entity].length - 1;
    uint256 indexToRemove = _getIndex(entity, item);
    _removeIndex(entity, item);

    // swap if not last
    if (indexToRemove != lastIndex) {
      entityToValue[entity][indexToRemove] = entityToValue[entity][lastIndex];
      _setIndex(entity, entityToValue[entity][indexToRemove], indexToRemove);
    }
    // pop
    entityToValue[entity].pop();

    IWorld(world).registerComponentValueSet(entity, abi.encode(entityToValue[entity]));
  }

  /**
   * Return stored index - 1. Index is 1-based for existence checks
   */
  function _getIndex(uint256 entity, uint256 item) internal view returns (uint256) {
    uint256 index = itemToIndex[entity][item];
    if (index == 0) revert Uint256SetComponent__ItemAbsent();
    return index - 1;
  }

  /**
   * Store `index` + 1. Index is 1-based for existence checks
   */
  function _setIndex(uint256 entity, uint256 item, uint256 index) internal {
    itemToIndex[entity][item] = index + 1;
  }

  /**
   * Set item's index to 0, which means the item doesn't exist
   */
  function _removeIndex(uint256 entity, uint256 item) internal {
    itemToIndex[entity][item] = 0;
  }

  function getEntities() public view virtual override returns (uint256[] memory) {
    revert Uint256SetComponent__NotImplemented();
  }

  function getEntitiesWithValue(bytes memory) public view virtual override returns (uint256[] memory) {
    revert Uint256SetComponent__NotImplemented();
  }

  function registerIndexer(address) external virtual {
    revert Uint256SetComponent__NotImplemented();
  }
}
