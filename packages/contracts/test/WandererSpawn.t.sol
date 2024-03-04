// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { DefaultWheel, Wanderer, GuisePrototype, ActiveCycle } from "../src/codegen/index.sol";

import { WandererSpawn } from "../src/wanderer/WandererSpawn.sol";
import { LibCycle } from "../src/cycle/LibCycle.sol";

contract WandererSpawnTest is MudLibTest {
  // taken from InitGuiseSystem, initialized by LibDeploy
  bytes32 warriorGuiseProtoEntity = keccak256("Warrior");
  bytes32 unigueEntity = getUniqueEntity();

  bytes32 wandererEntity;
  bytes32 cycleEntity;
  bytes32 defaultWheelEntity;

  function setUp() public virtual override {
    super.setUp();

    vm.prank(alice);
    wandererEntity = WandererSpawn.executeTyped(warriorGuiseProtoEntity);
    cycleEntity = ActiveCycle.get(wandererEntity);
    defaultWheelEntity = DefaultWheel.get();
  }

  function test_setUp_invalidGuise() public {
    vm.prank(alice);
    vm.expectRevert(LibCycle.LibCycle__InvalidGuiseProtoEntity.selector);
    WandererSpawn.executeTyped(0);
  }

  function test_initCycle_another() public {
    // initializing a cycle for some unrelated entity should work fine and produce an unrelated cycleEntity
    uint256 anotherCycleEntity = LibCycle.initCycle(
      world,
      world.getUniqueEntityId(),
      warriorGuiseProtoEntity,
      defaultWheelEntity
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
    assertEq(wNFTSystem.ownerOf(wandererEntity), alice);
  }

  function test_tokenOwner_notForCycleEntity() public {
    // cycleEntity shouldn't even be a token, this error refers to address(0)
    vm.expectRevert(IERC721BaseInternal.ERC721Base__InvalidOwner.selector);
    wNFTSystem.ownerOf(cycleEntity);
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
