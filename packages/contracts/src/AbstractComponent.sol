// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { IComponent } from "@latticexyz/solecs/src/interfaces/IComponent.sol";

/**
 * Components are a key-value store from entity id to component value.
 * They are registered in the World and register updates to their state in the World.
 * They have an owner, who can grant write access to more addresses.
 * (Systems that want to write to a component need to be given write access first.)
 * Everyone has read access.
 */
abstract contract AbstractComponent is IComponent {
  /** Reference to the World contract this component is registered in */
  address public world;

  /** Owner of the component has write access and can given write access to other addresses */
  address internal _owner;

  /** Addresses with write access to this component */
  mapping(address => bool) public writeAccess;

  /** Public identifier of this component */
  uint256 public id;

  constructor(address _world, uint256 _id) {
    _owner = msg.sender;
    writeAccess[msg.sender] = true;
    id = _id;
    if (_world != address(0)) registerWorld(_world);
  }

  /** Revert if caller is not the owner of this component */
  modifier onlyOwner() {
    require(msg.sender == _owner, "ONLY_OWNER");
    _;
  }

  /** Revert if caller does not have write access to this component */
  modifier onlyWriter() {
    require(writeAccess[msg.sender], "ONLY_WRITER");
    _;
  }

  /** Get the owner of this component */
  function owner() public view override returns (address) {
    return _owner;
  }

  /**
   * Transfer ownership of this component to a new owner.
   * Can only be called by the current owner.
   * @param newOwner Address of the new owner.
   */
  function transferOwnership(address newOwner) public override onlyOwner {
    //emit OwnershipTransferred(_owner, newOwner);
    writeAccess[msg.sender] = false;
    _owner = newOwner;
    writeAccess[newOwner] = true;
  }

  /**
   * Register this component in the given world.
   * @param _world Address of the World contract.
   */
  function registerWorld(address _world) public onlyOwner {
    world = _world;
    IWorld(world).registerComponent(address(this), id);
  }

  /**
   * Grant write access to this component to the given address.
   * Can only be called by the owner of this component.
   * @param writer Address to grant write access to.
   */
  function authorizeWriter(address writer) public override onlyOwner {
    writeAccess[writer] = true;
  }

  /**
   * Revoke write access to this component to the given address.
   * Can only be called by the owner of this component.
   * @param writer Address to revoke write access .
   */
  function unauthorizeWriter(address writer) public override onlyOwner {
    delete writeAccess[writer];
  }
}
