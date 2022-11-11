// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import {
  SkillType,
  TargetType,
  TimeStruct,
  EffectStatmod,
  SkillPrototype,
  SkillPrototypeComponent,
  ID as SkillPrototypeComponentID
} from "./SkillPrototypeComponent.sol";
import {
  SkillPrototypeExt,
  SkillPrototypeExtComponent,
  ID as SkillPrototypeExtComponentID
} from "./SkillPrototypeExtComponent.sol";
import { StatmodPrototypeComponent, ID as StatmodPrototypeComponentID } from "../statmod/StatmodPrototypeComponent.sol";

uint256 constant ID = uint256(keccak256("system.SkillPrototypeInit"));

contract SkillPrototypeInitSystem is System {
  error SkillPrototypeInitSystem__InvalidStatmod();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  struct Comps {
    SkillPrototypeComponent proto;
    SkillPrototypeExtComponent protoExt;
    StatmodPrototypeComponent statmod;
  }

  function execute(SkillPrototype memory prototype, SkillPrototypeExt memory prototypeExt) public {
    execute(abi.encode(prototype, prototypeExt));
  }

  function execute(bytes memory arguments) public onlyOwner returns (bytes memory) {
    (
      SkillPrototype memory prototype,
      SkillPrototypeExt memory prototypeExt
    ) = abi.decode(arguments, (SkillPrototype, SkillPrototypeExt));

    Comps memory comps = Comps({
      proto: SkillPrototypeComponent(getAddressById(components, SkillPrototypeComponentID)),
      protoExt: SkillPrototypeExtComponent(getAddressById(components, SkillPrototypeExtComponentID)),
      statmod: StatmodPrototypeComponent(getAddressById(components, StatmodPrototypeComponentID))
    });

    uint256 entity = uint256(keccak256(bytes(prototypeExt.name)));

    for (uint256 i; i < prototype.statmods.length; i++) {
      if (!comps.statmod.has(prototype.statmods[i].statmodProtoEntity)) {
        revert SkillPrototypeInitSystem__InvalidStatmod();
      }
    }

    comps.proto.set(entity, prototype);
    comps.protoExt.set(entity, prototypeExt);

    return '';
  }
}