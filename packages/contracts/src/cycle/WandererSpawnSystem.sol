// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { WNFTSubsystem, ID as WNFTSubsystemID } from "../token/WNFTSubsystem.sol";
import { GuisePrototypeComponent, ID as GuisePrototypeComponentID } from "../guise/GuisePrototypeComponent.sol";

import { LibCycle } from "../cycle/LibCycle.sol";

uint256 constant ID = uint256(keccak256("system.WandererSpawn"));

/// @title Spawn a wandererEntity and start a cycle for it.
/// @dev This is for new players, whereas StartCycleSystem is for existing ones.
contract WandererSpawnSystem is System {
  error WandererSpawnSystem__InvalidGuise();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(uint256 guiseProtoEntity) public returns (uint256 wandererEntity) {
    return abi.decode(
      execute(abi.encode(guiseProtoEntity)),
      (uint256)
    );
  }

  /// @notice Anyone can freely spawn wanderers, a wanderer is a tokenized game account
  function execute(bytes memory args) public override returns (bytes memory) {
    (uint256 guiseProtoEntity) = abi.decode(args, (uint256));

    // mint nft
    uint256 wandererEntity = world.getUniqueEntityId();
    WNFTSubsystem wnftSubsystem = WNFTSubsystem(getAddressById(world.systems(), WNFTSubsystemID));
    wnftSubsystem.executeSafeMint(msg.sender, wandererEntity, '');
    // TODO differentiate different types of nfts

    // init cycle
    LibCycle.initCycle(world, wandererEntity, guiseProtoEntity);

    return abi.encode(wandererEntity);
  }
}