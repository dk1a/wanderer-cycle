// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import {
  getGuiseProtoEntity,
  GuisePrototype,
  GuisePrototypeComponent,
  ID as GuisePrototypeComponentID
} from "../guise/GuisePrototypeComponent.sol";
import { GuiseSkillsComponent, ID as GuiseSkillsComponentID } from "../guise/GuiseSkillsComponent.sol";
import {
  getSkillProtoEntity as spe,
  SkillPrototypeComponent,
  ID as SkillPrototypeComponentID
} from "../skill/SkillPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

uint256 constant ID = uint256(keccak256("system.InitGuise"));

contract InitGuiseSystem is System {
  error GuisePrototypeInitSystem__InvalidSkill();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory) public override onlyOwner returns (bytes memory) {
    // TODO maybe move guise skills init to InitSkillSystem and have it depend on guise instead?
    uint256[] memory guiseSkills = new uint256[](11);
    guiseSkills[0]  = spe('Cleave');
    guiseSkills[1]  = spe('Charge');
    guiseSkills[2]  = spe('Parry');
    guiseSkills[3]  = spe('Onslaught');
    guiseSkills[4]  = spe('Toughness');
    guiseSkills[5]  = spe('Thunder Clap');
    guiseSkills[6]  = spe('Precise Strikes');
    guiseSkills[7]  = spe('Blood Rage');
    guiseSkills[8]  = spe('Retaliation');
    guiseSkills[9]  = spe('Last Stand');
    guiseSkills[10] = spe('Weapon Mastery');

    add(
      'Warrior',
      GuisePrototype({
        gainMul: [uint32(12), 6, 6],
        levelMul: [uint32(8), 0, 0]
      }),
      guiseSkills
    );

    return '';
  }

  function add(
    string memory name,
    GuisePrototype memory prototype,
    uint256[] memory guiseSkills
  ) internal {
    GuisePrototypeComponent proto = GuisePrototypeComponent(getAddressById(components, GuisePrototypeComponentID));
    GuiseSkillsComponent guiseSkillsComp = GuiseSkillsComponent(getAddressById(components, GuiseSkillsComponentID));
    SkillPrototypeComponent skillComp = SkillPrototypeComponent(getAddressById(components, SkillPrototypeComponentID));
    NameComponent nameComp = NameComponent(getAddressById(components, NameComponentID));

    uint256 entity = getGuiseProtoEntity(name);

    for (uint256 i; i < guiseSkills.length; i++) {
      if (!skillComp.has(guiseSkills[i])) {
        revert GuisePrototypeInitSystem__InvalidSkill();
      }
    }

    proto.set(entity, prototype);
    guiseSkillsComp.set(entity, guiseSkills);
    nameComp.set(entity, name);
  }
}