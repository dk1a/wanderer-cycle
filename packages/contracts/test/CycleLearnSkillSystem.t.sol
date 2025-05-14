// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IERC721Errors } from "@latticexyz/world-modules/src/modules/erc721-puppet/IERC721Errors.sol";

import { BaseTest } from "./BaseTest.t.sol";
import { LearnedSkills } from "../src/namespaces/skill/codegen/index.sol";

import { cycleLearnSkillSystem } from "../src/namespaces/cycle/codegen/systems/CycleLearnSkillSystemLib.sol";
import { LibGuise } from "../src/namespaces/root/guise/LibGuise.sol";
import { LibGuiseLevel } from "../src/namespaces/root/guise/LibGuiseLevel.sol";
import { LibSkill } from "../src/namespaces/skill/LibSkill.sol";
import { LibArray } from "../src/utils/LibArray.sol";

contract CycleLearnSkillSystemTest is BaseTest {
  bytes32 warriorGuiseEntity;

  bytes32 skillEntity1;
  bytes32 skillEntity2;
  bytes32 skillEntityInvalid;

  bytes32 wandererEntity;
  bytes32 cycleEntity;

  function setUp() public virtual override {
    super.setUp();

    // taken from LibInitGuise
    warriorGuiseEntity = LibGuise.getGuiseEntity("Warrior");

    // taken from LibInitSkill
    skillEntity1 = LibSkill.getSkillEntity("Cleave");
    skillEntity2 = LibSkill.getSkillEntity("Charge");
    skillEntityInvalid = keccak256("skillEntityInvalid");

    vm.prank(alice);
    (wandererEntity, cycleEntity) = world.spawnWanderer(warriorGuiseEntity);
  }

  function testSetUp() public view {
    assertEq(LibGuiseLevel.getAggregateLevel(cycleEntity), 1);
  }

  function testLearnSkill() public {
    vm.prank(alice);
    cycleLearnSkillSystem.learnSkill(cycleEntity, skillEntity1);
    assertTrue(LibArray.isIn(skillEntity1, LearnedSkills.get(cycleEntity)));
    assertEq(LearnedSkills.get(wandererEntity).length, 0);
  }

  function testLearnSkillRevertMustBeTokenOwner() public {
    vm.prank(bob);
    vm.expectPartialRevert(IERC721Errors.ERC721InsufficientApproval.selector);
    cycleLearnSkillSystem.learnSkill(cycleEntity, skillEntity1);
  }
}
