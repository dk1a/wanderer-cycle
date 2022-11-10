// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import {
  OP_L, EL_L,
  StatmodPrototype,
  StatmodPrototypeComponent,
  ID as StatmodPrototypeComponentID
} from "./StatmodPrototypeComponent.sol";
import {
  StatmodPrototypeExt,
  StatmodPrototypeExtComponent,
  ID as StatmodPrototypeExtComponentID
} from "./StatmodPrototypeExtComponent.sol";

uint256 constant ID = uint256(keccak256("system.StatmodInit"));

contract StatmodInitSystem is System {
  error StatmodInitSystem__LengthMismatch();
  error StatmodInitSystem__MalformedInput();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public onlyOwner returns (bytes memory) {
    (
      uint256[] memory entities,
      StatmodPrototype[] memory prototypes,
      StatmodPrototypeExt[] memory prototypesExt
    ) = abi.decode(arguments, (uint256[], StatmodPrototype[], StatmodPrototypeExt[]));

    if (entities.length != prototypes.length || prototypes.length != prototypesExt.length) {
      revert StatmodInitSystem__LengthMismatch();
    }

    StatmodPrototypeComponent protoComp
      = StatmodPrototypeComponent(getAddressById(components, StatmodPrototypeComponentID));
    StatmodPrototypeExtComponent protoExtComp
      = StatmodPrototypeExtComponent(getAddressById(components, StatmodPrototypeExtComponentID));

    for (uint256 i; i < entities.length; i++) {
      StatmodPrototypeExt memory protoExt = prototypesExt[i];

      // TODO add topic existence check if u make topic component
      if (bytes4(keccak256(bytes(protoExt.topic))) != prototypes[i].topic) {
        revert StatmodInitSystem__MalformedInput();
      }
      string memory expectedName = string(abi.encodePacked(
        protoExt.nameSplitForValue[0], '#', protoExt.nameSplitForValue[1]
      ));
      if (keccak256(bytes(protoExt.name)) != keccak256(bytes(expectedName))) {
        revert StatmodInitSystem__MalformedInput();
      }
      
      uint256 entity = entities[i];
      protoComp.set(entity, prototypes[i]);
      protoExtComp.set(entity, prototypesExt[i]);
    }

    return '';
  }
}