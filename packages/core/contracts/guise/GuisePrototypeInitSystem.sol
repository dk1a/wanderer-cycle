// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import {
  GuisePrototype,
  GuisePrototypeComponent,
  ID as GuisePrototypeComponentID
} from "./GuisePrototypeComponent.sol";
import {
  GuisePrototypeExt,
  GuisePrototypeExtComponent,
  ID as GuisePrototypeExtComponentID
} from "./GuisePrototypeExtComponent.sol";
import { GuiseSkillsComponent, ID as GuiseSkillsComponentID } from "./GuiseSkillsComponent.sol";
import { SkillPrototypeComponent, ID as SkillPrototypeComponentID } from "../skill/SkillPrototypeComponent.sol";

uint256 constant ID = uint256(keccak256("system.GuisePrototypeInit"));

contract GuisePrototypeInitSystem is System {
  error GuisePrototypeInitSystem__InvalidSkill();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  struct Comps {
    GuisePrototypeComponent proto;
    GuisePrototypeExtComponent protoExt;
    GuiseSkillsComponent guiseSkillsComp;
    SkillPrototypeComponent skillComp;
  }

  function execute(
    GuisePrototype memory prototype,
    GuisePrototypeExt memory prototypeExt,
    uint256[] memory guiseSkills
  ) public {
    execute(abi.encode(prototype, prototypeExt, guiseSkills));
  }

  function execute(bytes memory arguments) public onlyOwner returns (bytes memory) {
    (
      GuisePrototype memory prototype,
      GuisePrototypeExt memory prototypeExt,
      uint256[] memory guiseSkills
    ) = abi.decode(arguments, (GuisePrototype, GuisePrototypeExt, uint256[]));

    Comps memory comps = Comps({
      proto: GuisePrototypeComponent(getAddressById(components, GuisePrototypeComponentID)),
      protoExt: GuisePrototypeExtComponent(getAddressById(components, GuisePrototypeExtComponentID)),
      guiseSkillsComp: GuiseSkillsComponent(getAddressById(components, GuiseSkillsComponentID)),
      skillComp: SkillPrototypeComponent(getAddressById(components, SkillPrototypeComponentID))
    });

    uint256 entity = uint256(keccak256(bytes(prototypeExt.name)));

    for (uint256 i; i < guiseSkills.length; i++) {
      if (!comps.skillComp.has(guiseSkills[i])) {
        revert GuisePrototypeInitSystem__InvalidSkill();
      }
    }

    comps.proto.set(entity, prototype);
    comps.protoExt.set(entity, prototypeExt);
    comps.guiseSkillsComp.set(entity, guiseSkills);

    return '';
  }
}