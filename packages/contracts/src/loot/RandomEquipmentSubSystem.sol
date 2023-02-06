// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";
import { Subsystem } from "@dk1a/solecslib/contracts/mud/Subsystem.sol";

import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";

import { LibLootEquipment } from "./LibLootEquipment.sol";
import { LibLootMint } from "./LibLootMint.sol";

uint256 constant ID = uint256(keccak256("system.RandomEquipment"));

/// @title Mint a random equippable loot entity.
contract RandomEquipmentSubSystem is Subsystem {
  constructor(IWorld _world, address _components) Subsystem(_world, _components) {}

  /// @param ilvl higher ilvl increases the pool of affixes for random generation (higher is better).
  /// @param randomness used to randomly pick equipment prototype and affixes.
  /// @return lootEntity a new entity.
  function executeTyped(uint32 ilvl, uint256 randomness) public returns (uint256 lootEntity) {
    return abi.decode(execute(abi.encode(ilvl, randomness)), (uint256));
  }

  function _execute(bytes memory args) internal override returns (bytes memory) {
    (uint32 ilvl, uint256 randomness) = abi.decode(args, (uint32, uint256));

    // pick equipment prototype (it's the targetEntity when getting affix availability)
    uint256 equipmentProtoEntity = LibLootEquipment.pickEquipmentPrototype(ilvl, randomness);
    // get a new unique id
    uint256 lootEntity = world.getUniqueEntityId();
    // make random loot (affixes and effect)
    LibLootMint.randomLootMint(
      components,
      LibLootEquipment.getAffixPartIds(ilvl),
      lootEntity,
      equipmentProtoEntity,
      ilvl,
      randomness
    );
    // set loot's equipment prototype (to make it equippable)
    FromPrototypeComponent fromProtoComp = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));
    fromProtoComp.set(lootEntity, equipmentProtoEntity);

    return abi.encode(lootEntity);
  }
}
