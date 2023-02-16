// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { WNFTSystem, ID as WNFTSystemID } from "../token/WNFTSystem.sol";
import { WandererComponent, ID as WandererComponentID } from "./WandererComponent.sol";
import { GuisePrototypeComponent, ID as GuisePrototypeComponentID } from "../guise/GuisePrototypeComponent.sol";

import { LibCycle } from "../cycle/LibCycle.sol";

// TODO imports for testing stuff, remove later
import { RandomEquipmentSubSystem, ID as RandomEquipmentSubSystemID } from "../loot/RandomEquipmentSubSystem.sol";
import { LibLootOwner } from "../loot/LibLootOwner.sol";

uint256 constant ID = uint256(keccak256("system.WandererSpawn"));

/// @title Spawn a wandererEntity and start a cycle for it.
/// @dev This is for new players, whereas StartCycleSystem is for existing ones.
contract WandererSpawnSystem is System {
  error WandererSpawnSystem__InvalidGuise();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(uint256 guiseProtoEntity) public returns (uint256 wandererEntity) {
    return abi.decode(execute(abi.encode(guiseProtoEntity)), (uint256));
  }

  /// @notice Anyone can freely spawn wanderers, a wanderer is a tokenized game account
  function execute(bytes memory args) public override returns (bytes memory) {
    uint256 guiseProtoEntity = abi.decode(args, (uint256));

    // mint nft
    uint256 wandererEntity = world.getUniqueEntityId();
    WNFTSystem wnftSystem = WNFTSystem(getAddressById(world.systems(), WNFTSystemID));
    wnftSystem.executeSafeMint(msg.sender, wandererEntity, "");

    // flag the entity as wanderer
    WandererComponent wandererComp = WandererComponent(getAddressById(components, WandererComponentID));
    wandererComp.set(wandererEntity);

    // init cycle
    LibCycle.initCycle(world, wandererEntity, guiseProtoEntity);

    // TODO loot for testing, remove later
    {
      RandomEquipmentSubSystem randomEquipmentSubSystem = RandomEquipmentSubSystem(
        getAddressById(world.systems(), RandomEquipmentSubSystemID)
      );
      uint256 lootEntity;
      lootEntity = randomEquipmentSubSystem.executeTyped(1, 123);
      LibLootOwner.setSimpleOwnership(components, lootEntity, addressToEntity(msg.sender));
      lootEntity = randomEquipmentSubSystem.executeTyped(2, 456);
      LibLootOwner.setSimpleOwnership(components, lootEntity, addressToEntity(msg.sender));
      lootEntity = randomEquipmentSubSystem.executeTyped(10, 789);
      LibLootOwner.setSimpleOwnership(components, lootEntity, addressToEntity(msg.sender));
      lootEntity = randomEquipmentSubSystem.executeTyped(12, 101112);
      LibLootOwner.setSimpleOwnership(components, lootEntity, addressToEntity(msg.sender));
    }

    return abi.encode(wandererEntity);
  }
}
