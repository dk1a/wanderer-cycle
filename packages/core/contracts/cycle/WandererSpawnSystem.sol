// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { WNFTSystem, ID as WNFTSystemID } from "../token/WNFTSystem.sol";
import { GuisePrototypeComponent, ID as GuisePrototypeComponentID } from "../guise/GuisePrototypeComponent.sol";

import { LibCycle } from "../cycle/LibCycle.sol";

uint256 constant ID = uint256(keccak256("system.WandererSpawn"));

contract WandererSpawnSystem is System {
  using LibCycle for LibCycle.Self;

  error WandererSpawnSystem__InvalidGuise();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(uint256 guiseProtoEntity) public returns (uint256 wandererEntity) {
    return abi.decode(
      execute(abi.encode(guiseProtoEntity)),
      (uint256)
    );
  }

  /**
   * @notice Anyone can freely spawn wanderers, a wanderer is a tokenized game account
   */
  function execute(bytes memory arguments) public override returns (bytes memory) {
    (uint256 guiseProtoEntity) = abi.decode(arguments, (uint256));

    // check guise
    GuisePrototypeComponent guiseProtoComp
      = GuisePrototypeComponent(getAddressById(components, GuisePrototypeComponentID));
    if (!guiseProtoComp.has(guiseProtoEntity)) {
      revert WandererSpawnSystem__InvalidGuise();
    }

    // mint nft
    uint256 wandererEntity = world.getUniqueEntityId();
    WNFTSystem wnftSystem = WNFTSystem(getAddressById(world.systems(), WNFTSystemID));
    wnftSystem.executeSafeMint(msg.sender, wandererEntity, '');
    // TODO differentiate different types of nfts

    // init cycle
    uint256 cycleEntity = world.getUniqueEntityId();
    LibCycle.Self memory cycle = LibCycle.__construct(components, wandererEntity);
    cycle.initCycle(cycleEntity, guiseProtoEntity);

    return abi.encode(wandererEntity);
  }
}