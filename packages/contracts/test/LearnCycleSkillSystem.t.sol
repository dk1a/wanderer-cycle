// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { CycleToWanderer, GuiseNameToEntity, SkillNameToEntity, LearnedSkills } from "../src/namespaces/root/codegen/index.sol";

import { LibGuiseLevel } from "../src/namespaces/root/guise/LibGuiseLevel.sol";
import { LibERC721 } from "../src/namespaces/root/token/LibERC721.sol";
import { LibArray } from "../src/namespaces/root/utils/LibArray.sol";

contract LearnCycleSkillSystemTest is MudLibTest {
  bytes32 warriorGuiseProtoEntity;

  bytes32 skillEntity1;
  bytes32 skillEntity2;
  bytes32 skillEntityInvalid;

  bytes32 wandererEntity;
  bytes32 cycleEntity;

  function setUp() public virtual override {
    super.setUp();

    // taken from LibInitGuise
    warriorGuiseProtoEntity = GuiseNameToEntity.get(keccak256("Warrior"));

    // taken from LibInitSkill
    skillEntity1 = SkillNameToEntity.get(keccak256("Cleave"));
    skillEntity2 = SkillNameToEntity.get(keccak256("Charge"));
    skillEntityInvalid = keccak256("skillEntityInvalid");

    vm.prank(alice);
    (wandererEntity, cycleEntity) = world.spawnWanderer(warriorGuiseProtoEntity);
  }

  function test_setUp() public {
    assertEq(LibGuiseLevel.getAggregateLevel(cycleEntity), 1);
  }

  function test_learnSkill() public {
    vm.prank(alice);
    world.learnFromCycle(wandererEntity, skillEntity1);
    assertTrue(LibArray.isIn(skillEntity1, LearnedSkills.get(cycleEntity)));
    assertEq(LearnedSkills.get(wandererEntity).length, 0);
  }

  function test_learnSkill_notTokenOwner() public {
    vm.prank(bob);
    vm.expectRevert(LibERC721.LibERC721_MustBeTokenOwner.selector);
    world.learnFromCycle(wandererEntity, skillEntity1);
  }
}
