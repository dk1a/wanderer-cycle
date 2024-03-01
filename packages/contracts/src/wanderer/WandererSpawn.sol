// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { DefaultWheel, Wanderer, GuisePrototype } from "../codegen/index.sol";

import { LibCycle } from "../cycle/LibCycle.sol";

/// @title Spawn a wandererEntity and start a cycle for it.
/// @dev This is for new players, whereas StartCycle is for existing ones.
contract WandererSpawn {
  error WandererSpawn__InvalidGuise();

  function executeTyped(bytes32 guiseProtoEntity) public returns (bytes32 wandererEntity) {
    return abi.decode(execute(abi.encode(guiseProtoEntity)), (bytes32));
  }

  /// @notice Anyone can freely spawn wanderers, a wanderer is a tokenized game account
  function execute(bytes memory args) public returns (bytes memory) {
    bytes32 guiseProtoEntity = abi.decode(args, (bytes32));

    // mint nft
    bytes32 wandererEntity = getUniqueEntity();
    // wnftSystem.executeSafeMint(msg.sender, wandererEntity, "");

    // flag the entity as wanderer
    Wanderer.set(wandererEntity, true);

    bytes32 defaultWheelEntity = DefaultWheel.get();

    // init cycle
    LibCycle.initCycle(wandererEntity, guiseProtoEntity, defaultWheelEntity);

    return abi.encode(wandererEntity);
  }
}
