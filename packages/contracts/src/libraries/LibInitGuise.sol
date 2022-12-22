// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { GuisePrototypeInitSystem, ID as GuisePrototypeInitSystemID } from "../guise/GuisePrototypeInitSystem.sol";
import {
  GuisePrototype,
  GuisePrototypeComponent,
  ID as GuisePrototypeComponentID
} from "../guise/GuisePrototypeComponent.sol";
import {
  GuisePrototypeExt,
  GuisePrototypeExtComponent,
  ID as GuisePrototypeExtComponentID
} from "../guise/GuisePrototypeExtComponent.sol";
import { GuiseSkillsComponent, ID as GuiseSkillsComponentID } from "../guise/GuiseSkillsComponent.sol";

library LibInitGuise {
  function initialize(IWorld world) internal {
    GuisePrototypeInitSystem system = GuisePrototypeInitSystem(getAddressById(world.systems(), GuisePrototypeInitSystemID));

    // TODO maybe move guise skills init to LibInitSkill and have it depend on guise instead?
    uint256[] memory guiseSkills = new uint256[](11);
    guiseSkills[0] = uint256(keccak256('Cleave'));
    guiseSkills[1] = uint256(keccak256('Charge'));
    guiseSkills[2] = uint256(keccak256('Parry'));
    guiseSkills[3] = uint256(keccak256('Onslaught'));
    guiseSkills[4] = uint256(keccak256('Toughness'));
    guiseSkills[5] = uint256(keccak256('Thunder Clap'));
    guiseSkills[6] = uint256(keccak256('Precise Strikes'));
    guiseSkills[7] = uint256(keccak256('Blood Rage'));
    guiseSkills[8] = uint256(keccak256('Retaliation'));
    guiseSkills[9] = uint256(keccak256('Last Stand'));
    guiseSkills[10] = uint256(keccak256('Weapon Mastery'));

    system.execute(
      GuisePrototype({
        gainMul: [uint32(12), 6, 6],
        levelMul: [uint32(8), 0, 0]
      }),
      GuisePrototypeExt({
        name: 'Warrior'
      }),
      guiseSkills
    );
  }
}