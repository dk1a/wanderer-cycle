// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";
import { Subsystem } from "@latticexyz/solecs/src/Subsystem.sol";

import { LibPickAffixes } from "./LibPickAffixes.sol";
import { LibPickEquipmentPrototype } from "./LibPickEquipmentPrototype.sol";
import { AffixPartId } from "./AffixNamingComponent.sol";

import { Loot, LootComponent, ID as LootComponentID } from "./LootComponent.sol";
import {
  AffixPrototype,
  AffixPrototypeComponent,
  ID as AffixPrototypeComponentID
} from "./AffixPrototypeComponent.sol";
import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";
import { EffectRemovability, EffectPrototype, LibEffectPrototype } from "../effect/LibEffectPrototype.sol";
import { WNFTSubsystem, ID as WNFTSubsystemID } from "../token/WNFTSubsystem.sol";

uint256 constant ID = uint256(keccak256("system.LootMint"));

/// @title Mint a random equippable loot NFT.
contract LootMintSubsystem is Subsystem {
  error LootMintSubsystem__InvalidIlvl(uint256 ilvl);
  error LootMintSubsystem__InvalidMinMax();

  constructor(IWorld _world, address _components) Subsystem(_world, _components) {}

  /// @param account address that receives the loot NFT.
  /// @param ilvl higher ilvl increases the pool of affixes for random generation (higher is better).
  /// @param randomness used to randomly pick equipment prototype and affixes.
  /// @return lootEntity a new entity and an NFT id.
  function executeTyped(
    address account,
    uint256 ilvl,
    uint256 randomness
  ) public returns (uint256 lootEntity) {
    return abi.decode(
      execute(abi.encode(account, ilvl, randomness)),
      (uint256)
    );
  }

  function _execute(bytes memory args) internal override returns (bytes memory) {
    (
      address account,
      uint256 ilvl,
      uint256 randomness
    ) = abi.decode(args, (address, uint256, uint256));

    // pick equipment prototype
    uint256 equipmentProtoEntity = LibPickEquipmentPrototype.pickEquipmentPrototype(ilvl, randomness);
    // pick affixes
    (
      uint256[] memory statmodProtoEntities,
      uint256[] memory affixProtoEntities,
      uint256[] memory affixValues
    ) = LibPickAffixes.pickAffixes(
      components,
      equipmentProtoEntity,
      ilvl,
      randomness
    );

    // get a new unique id
    uint256 lootEntity = world.getUniqueEntityId();
    // save loot-specific data
    LootComponent lootComp = LootComponent(getAddressById(components, LootComponentID));
    lootComp.set(lootEntity, Loot({
      ilvl: ilvl,
      affixProtoEntities: affixProtoEntities,
      affixValues: affixValues
    }));
    // set loot's equipment prototype (to make it equippable)
    FromPrototypeComponent fromProtoComp = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));
    fromProtoComp.set(lootEntity, equipmentProtoEntity);
    // save loot as an effect prototype (the effect triggers on-equip)
    LibEffectPrototype.verifiedSet(
      components,
      lootEntity,
      EffectPrototype({
        removability: EffectRemovability.PERSISTENT,
        statmodProtoEntities: statmodProtoEntities,
        statmodValues: affixValues
      })
    );
    // mint an NFT for the loot (to allow standardized URI viewing, and make it potentially tradeable)
    WNFTSubsystem wnftSubsystem = WNFTSubsystem(getAddressById(world.systems(), WNFTSubsystemID));
    wnftSubsystem.executeSafeMint(account, lootEntity, '');

    return abi.encode(lootEntity);
  }
}