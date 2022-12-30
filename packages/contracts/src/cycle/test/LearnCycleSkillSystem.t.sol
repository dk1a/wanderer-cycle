// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { ERC721BaseInternal } from "@dk1a/solecslib/contracts/token/ERC721/logic/ERC721BaseInternal.sol";

import { getGuiseProtoEntity } from "../../guise/GuisePrototypeComponent.sol";
import { getSkillProtoEntity } from "../../skill/SkillPrototypeComponent.sol";
import { LibCycle } from "../LibCycle.sol";
import { LibGuiseLevel } from "../../guise/LibGuiseLevel.sol";
import { LibToken } from "../../token/LibToken.sol";

contract LearnCycleSkillSystemTest is BaseTest {
  // taken from InitGuiseSystem, initialized by LibDeploy
  uint256 warriorGuiseProtoEntity = getGuiseProtoEntity("Warrior");

  // taken from InitSkillSystem, initialized by LibDeploy
  uint256 skillEntity1 = getSkillProtoEntity("Cleave");
  uint256 skillEntity2 = getSkillProtoEntity("Charge");
  uint256 skillEntityInvalid = uint256(keccak256("skillEntityInvalid"));

  uint256 wandererEntity;
  uint256 cycleEntity;

  function setUp() public virtual override {
    super.setUp();

    vm.prank(alice);
    wandererEntity = wandererSpawnSystem.executeTyped(warriorGuiseProtoEntity);
    cycleEntity = activeCycleComponent.getValue(wandererEntity);
  }

  function test_setUp() public {
    assertEq(LibGuiseLevel.getAggregateLevel(components, cycleEntity), 1);
  }

  function test_learnSkill() public {
    vm.prank(alice);
    learnCycleSkillSystem.executeTyped(wandererEntity, skillEntity1);
    assertTrue(learnedSkillsComponent.hasItem(cycleEntity, skillEntity1));
    assertFalse(learnedSkillsComponent.has(wandererEntity));
  }

  function test_learnSkill_notTokenOwner() public {
    vm.prank(bob);
    vm.expectRevert(LibToken.LibToken_MustBeTokenOwner.selector);
    learnCycleSkillSystem.executeTyped(wandererEntity, skillEntity1);
  }
}