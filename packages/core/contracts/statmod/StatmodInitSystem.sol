// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { statmodName } from "./utils.sol";
import {
  getStatmodProtoEntity,
  StatmodPrototype,
  StatmodPrototypeComponent,
  ID as StatmodPrototypeComponentID
} from "./StatmodPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

uint256 constant ID = uint256(keccak256("system.StatmodInit"));

contract StatmodInitSystem is System {
  error StatmodInitSystem__MalformedInput();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(
    StatmodPrototype memory prototype
  ) public {
    execute(abi.encode(prototype));
  }

  function execute(bytes memory args) public override onlyOwner returns (bytes memory) {
    (
      StatmodPrototype memory prototype
    ) = abi.decode(args, (StatmodPrototype));

    StatmodPrototypeComponent protoComp
      = StatmodPrototypeComponent(getAddressById(components, StatmodPrototypeComponentID));
    NameComponent nameComp
      = NameComponent(getAddressById(components, NameComponentID));

    uint256 protoEntity = getStatmodProtoEntity(prototype);
    protoComp.set(protoEntity, prototype);

    string memory name = statmodName(world, prototype.topicEntity, prototype.op, prototype.element);
    nameComp.set(protoEntity, name);

    return '';
  }
}