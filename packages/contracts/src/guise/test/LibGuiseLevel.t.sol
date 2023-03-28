// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";

import "forge-std/console.sol";

import { LibExperience } from "../../charstat/LibExperience.sol";
import { LibGuiseLevel } from "../LibGuiseLevel.sol";
import { ActiveGuiseComponent, ID as ActiveGuiseComponentID } from "../ActiveGuiseComponent.sol";
import { GuisePrototypeComponent, ID as GuisePrototypeComponentID } from "../GuisePrototypeComponent.sol";
import { getGuiseProtoEntity } from "../GuisePrototypeComponent.sol";
import { getSkillProtoEntity } from "../../skill/SkillPrototypeComponent.sol";
import { LibSkill } from "../../skill/LibSkill.sol";
import { LibLearnedSkills } from "../../skill/LibLearnedSkills.sol";

contract LibGuiseLevelTest is BaseTest {
  using LibExperience for LibExperience.Self;
  using LibSkill for LibSkill.Self;
  using LibLearnedSkills for LibLearnedSkills.Self;

  LibLearnedSkills.Self learnedSkills;
  // entities
  uint256 userEntity = uint256(keccak256("userEntity"));
  uint256 otherEntity = uint256(keccak256("otherEntity"));

  // guise
  uint256 guise = getGuiseProtoEntity("Warrior");

  uint256 cleavePE = getSkillProtoEntity("Cleave");
  uint256 chargePE = getSkillProtoEntity("Charge");
  uint256 parryPE = getSkillProtoEntity("Parry");
  uint256 someInvalidSkillPE = getSkillProtoEntity("someInvalidSkill");

  function setUp() public virtual override {
    super.setUp();
    learnedSkills = LibLearnedSkills.__construct(world, userEntity);

    // give user some mana
    // allow user to receive experience

    // learn sample skills
    learnedSkills.learnSkill(cleavePE);
    learnedSkills.learnSkill(chargePE);
    learnedSkills.learnSkill(parryPE);

    console.log("guise guise guise");
  }

  function test_guise() public {}

  function testSetup() public {
    assertTrue(learnedSkills.hasSkill(cleavePE));
    assertTrue(learnedSkills.hasSkill(chargePE));
    assertTrue(learnedSkills.hasSkill(parryPE));
  }

  function test_hasSkill_invalidSkill() public {
    assertFalse(learnedSkills.hasSkill(someInvalidSkillPE));
  }
}
