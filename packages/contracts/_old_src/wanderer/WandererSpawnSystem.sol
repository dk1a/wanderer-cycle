// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";
import { SingletonID } from "../SingletonID.sol";

import { WNFTSystem, ID as WNFTSystemID } from "../token/WNFTSystem.sol";
import { WandererComponent, ID as WandererComponentID } from "./WandererComponent.sol";
import { GuisePrototypeComponent, ID as GuisePrototypeComponentID } from "../guise/GuisePrototypeComponent.sol";
import { DefaultWheelComponent, ID as DefaultWheelComponentID } from "../wheel/DefaultWheelComponent.sol";

import { LibCycle } from "../cycle/LibCycle.sol";

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

    DefaultWheelComponent defaultWheelComp = DefaultWheelComponent(getAddressById(components, DefaultWheelComponentID));
    uint256 defaultWheelEntity = defaultWheelComp.getValue(SingletonID);

    // init cycle
    LibCycle.initCycle(world, wandererEntity, guiseProtoEntity, defaultWheelEntity);

    return abi.encode(wandererEntity);
  }
}
