// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { LibTypes } from "@latticexyz/solecs/src/LibTypes.sol";
import { MapSetBatchable } from "./MapSetBatchable.sol";
import { AbstractComponent } from "./AbstractComponent.sol";

/**
 * The main purpose of SetComponent is hasItem method,
 * which allows to check existence in O(1) instead of reading the whole array.
 *
 * There's also addItem and removeItem, which don't write the whole array
 * (though they still read it all for world value registration).
 */
contract Uint256SetComponent is AbstractComponent {
  error BareComponent__NotImplemented();

  MapSetBatchable internal entityToItemSet;

  constructor(address _world, uint256 _id) AbstractComponent(_world, _id) {
    entityToItemSet = new MapSetBatchable();
  }

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
    return itemSetSize(entity) != 0;
  }

  /**
   * Get size of entity's item set
   * Set-specific
   */
  function itemSetSize(uint256 entity) public view virtual returns (uint256) {
    return entityToItemSet.size(entity);
  }

  function getRawValue(uint256 entity) public view virtual override returns (bytes memory) {
    return abi.encode(getValue(entity));
  }

  function getValue(uint256 entity) public view virtual returns (uint256[] memory) {
    return entityToItemSet.getItems(entity);
  }

  /**
   * Check if set has `item` in O(1)
   * Set-specific
   */
  function hasItem(uint256 entity, uint256 item) public view virtual returns (bool) {
    return entityToItemSet.has(entity, item);
  }

  /**
   * Add an item without writing the whole array
   * Set-specific
   */
  function addItem(uint256 entity, uint256 item) public onlyWriter {
    _addItem(entity, item);
  }

  /**
   * Remove an item without writing the whole array
   * Set-specific
   */
  function removeItem(uint256 entity, uint256 item) public onlyWriter {
    _removeItem(entity, item);
  }

  function _set(uint256 entity, uint256[] memory items) internal virtual {
    entityToItemSet.replaceAll(entity, items);

    IWorld(world).registerComponentValueSet(entity, abi.encode(items));
  }

  function _remove(uint256 entity) internal virtual {
    entityToItemSet.removeAll(entity);

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

    entityToItemSet.add(entity, item);

    IWorld(world).registerComponentValueSet(entity, abi.encode(entityToItemSet.getItems(entity)));
  }

  /**
   * Remove an item without writing the whole array
   */
  function _removeItem(uint256 entity, uint256 item) internal virtual {
    if (!hasItem(entity, item)) {
      // item is not in set
      return;
    }

    entityToItemSet.remove(entity, item);

    IWorld(world).registerComponentValueSet(entity, abi.encode(entityToItemSet.getItems(entity)));
  }

  function getEntities() public view virtual override returns (uint256[] memory) {
    revert BareComponent__NotImplemented();
  }

  function getEntitiesWithValue(bytes memory) public view virtual override returns (uint256[] memory) {
    revert BareComponent__NotImplemented();
  }

  function registerIndexer(address) external virtual {
    revert BareComponent__NotImplemented();
  }
}
