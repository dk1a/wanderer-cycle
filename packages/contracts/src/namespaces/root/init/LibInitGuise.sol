// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { PStat_length } from "../../../CustomTypes.sol";
import { GuisePrototype, GuiseName, GuiseSkills, Name } from "../codegen/index.sol";

import { LibSkill as ls } from "../skill/LibSkill.sol";

library LibInitGuise {
  error LibInitGuise_DuplicateName(string name);

  function init() internal {
    // TODO maybe move guise skills init to LibInitSkill and have it depend on guise instead?
    bytes32[] memory guiseSkills = new bytes32[](11);
    guiseSkills[0] = ls.getSkillEntity("Cleave");
    guiseSkills[1] = ls.getSkillEntity("Charge");
    guiseSkills[2] = ls.getSkillEntity("Parry");
    guiseSkills[3] = ls.getSkillEntity("Onslaught");
    guiseSkills[4] = ls.getSkillEntity("Toughness");
    guiseSkills[5] = ls.getSkillEntity("Thunder Clap");
    guiseSkills[6] = ls.getSkillEntity("Precise Strikes");
    guiseSkills[7] = ls.getSkillEntity("Blood Rage");
    guiseSkills[8] = ls.getSkillEntity("Retaliation");
    guiseSkills[9] = ls.getSkillEntity("Last Stand");
    guiseSkills[10] = ls.getSkillEntity("Weapon Mastery");

    add("Warrior", [uint32(16), 8, 8], guiseSkills);
  }

  function add(string memory name, uint32[PStat_length] memory pstat, bytes32[] memory guiseSkills) internal {
    bytes32 entity = getUniqueEntity();

    GuisePrototype.set(entity, pstat);
    GuiseName.set(entity, name);
    GuiseSkills.set(entity, guiseSkills);
  }
}
