// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";
import { Subsystem } from "@dk1a/solecslib/contracts/mud/Subsystem.sol";

import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";

import { LibLootMap } from "./LibLootMap.sol";
import { LibLootMint } from "./LibLootMint.sol";

uint256 constant ID = uint256(keccak256("system.RandomMap"));

/// @title Mint a random map entity.
contract RandomMapSubSystem is Subsystem {
  constructor(IWorld _world, address _components) Subsystem(_world, _components) {}

  /// @param ilvl higher ilvl increases the pool of affixes for random generation (higher is better).
  /// @param mapProtoEntity map prototype.
  /// @param randomness used to randomly pick equipment prototype and affixes.
  /// @return lootEntity a new entity.
  function executeTyped(uint32 ilvl, uint256 mapProtoEntity, uint256 randomness) public returns (uint256 lootEntity) {
    return abi.decode(execute(abi.encode(ilvl, mapProtoEntity, randomness)), (uint256));
  }

  function _execute(bytes memory args) internal override returns (bytes memory) {
    (uint32 ilvl, uint256 mapProtoEntity, uint256 randomness) = abi.decode(args, (uint32, uint256, uint256));

    // get a new unique id
    uint256 lootEntity = world.getUniqueEntityId();
    // make random loot (affixes and effect)
    LibLootMint.randomLootMint(
      components,
      LibLootMap.getAffixPartIds(ilvl),
      lootEntity,
      mapProtoEntity,
      ilvl,
      randomness
    );
    // set loot's map prototype
    FromPrototypeComponent fromProtoComp = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));
    fromProtoComp.set(lootEntity, mapProtoEntity);

    return abi.encode(lootEntity);
  }
}
