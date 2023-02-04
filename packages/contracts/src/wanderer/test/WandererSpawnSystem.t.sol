// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { ERC721BaseInternal } from "@dk1a/solecslib/contracts/token/ERC721/logic/ERC721BaseInternal.sol";

import { getGuiseProtoEntity } from "../../guise/GuisePrototypeComponent.sol";
import { LibCycle } from "../../cycle/LibCycle.sol";

contract WandererSpawnSystemTest is BaseTest {
  // taken from InitGuiseSystem, initialized by LibDeploy
  uint256 warriorGuiseProtoEntity = getGuiseProtoEntity("Warrior");

  uint256 wandererEntity;
  uint256 cycleEntity;

  function setUp() public virtual override {
    super.setUp();

    vm.prank(alice);
    wandererEntity = wandererSpawnSystem.executeTyped(warriorGuiseProtoEntity);
    cycleEntity = activeCycleComponent.getValue(wandererEntity);
  }

  function test_setUp_invalidGuise() public {
    vm.prank(alice);
    vm.expectRevert(LibCycle.LibCycle__InvalidGuiseProtoEntity.selector);
    wandererSpawnSystem.executeTyped(0);
  }

  function test_initCycle_another() public {
    // initializing a cycle for some unrelated entity should work fine and produce an unrelated cycleEntity
    uint256 anotherCycleEntity = LibCycle.initCycle(
      world,
      world.getUniqueEntityId(),
      warriorGuiseProtoEntity
    );
    assertNotEq(anotherCycleEntity, cycleEntity);
  }

  function test_entities() public { 
    assertNotEq(cycleEntity, wandererEntity);
    assertNotEq(cycleEntity, 0);
  }

  // wandererEntity has all the components unrelated to cycles

  function test_wanderer() public {
    assertTrue(wandererComponent.getValue(wandererEntity));
  }

  function test_tokenOwner() public {
    assertEq(wNFTSubsystem.ownerOf(wandererEntity), alice);
  }

  function test_tokenOwner_notForCycleEntity() public {
    // cycleEntity shouldn't even be a token, this error refers to address(0)
    vm.expectRevert(ERC721BaseInternal.ERC721Base__InvalidOwner.selector);
    wNFTSubsystem.ownerOf(cycleEntity);
  }

  // cycleEntity has all the in-cycle components

  function test_activeGuise() public {
    assertEq(activeGuiseComponent.getValue(cycleEntity), warriorGuiseProtoEntity);
    assertFalse(activeGuiseComponent.has(wandererEntity));
  }

  function test_experience() public {
    assertTrue(experienceComponent.has(cycleEntity));
    // TODO wandererEntity could have exp for some non-cycle-related reasons, come back to this later
    // TODO (same thing with currents, though less likely)
    assertFalse(experienceComponent.has(wandererEntity));
  }

  function test_currents() public {
    assertGt(lifeCurrentComponent.getValue(cycleEntity), 0);
    assertFalse(lifeCurrentComponent.has(wandererEntity));

    assertGt(manaCurrentComponent.getValue(cycleEntity), 0);
    assertFalse(manaCurrentComponent.has(wandererEntity));
  }

  function test_cycleTurns() public {
    assertGt(cycleTurnsComponent.getValue(cycleEntity), 0);
    assertFalse(cycleTurnsComponent.has(wandererEntity));
  }
}