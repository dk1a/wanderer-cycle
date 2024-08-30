// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";
import { hasKey } from "@latticexyz/world-modules/src/modules/keysintable/hasKey.sol";

import { ActiveGuise, DefaultWheel, Wanderer, GuisePrototype, ActiveCycle, CycleTurns, LifeCurrent, ManaCurrent } from "../src/codegen/index.sol";

import { LibCycle } from "../src/cycle/LibCycle.sol";
import { LibGuise } from "../src/guise/LibGuise.sol";
import { LibExperience } from "../src/charstat/LibExperience.sol";
import { ERC721Namespaces } from "../src/token/ERC721Namespaces.sol";

contract WandererSpawnSystemTest is MudLibTest {
  bytes32 guiseEntity;

  bytes32 wandererEntity;
  bytes32 cycleEntity;
  bytes32 defaultWheelEntity;

  function setUp() public virtual override {
    super.setUp();

    guiseEntity = LibGuise.getGuiseEntity("Warrior");

    // wandererEntity has all the permanent player data (not related to a specific cycle)
    vm.prank(alice);
    (wandererEntity, cycleEntity) = world.spawnWanderer(guiseEntity);
    defaultWheelEntity = DefaultWheel.get();
  }

  function test_setUp_invalidGuise() public {
    vm.prank(alice);
    vm.expectRevert(LibCycle.LibCycle_InvalidGuiseProtoEntity.selector);
    world.spawnWanderer(keccak256("invalid guise"));
  }

  function test_initCycle_another() public {
    // initializing a cycle for some unrelated entity should work fine and produce an unrelated cycleEntity
    bytes32 anotherCycleEntity = LibCycle.initCycle(getUniqueEntity(), guiseEntity, defaultWheelEntity);
    assertNotEq(anotherCycleEntity, cycleEntity);
  }

  function test_entities() public {
    assertNotEq(cycleEntity, wandererEntity);
    assertNotEq(cycleEntity, 0);
  }

  function test_wanderer() public {
    assertTrue(Wanderer.get(wandererEntity));
  }

  function test_tokenOwner() public {
    assertEq(ERC721Namespaces.WandererNFT.ownerOf(wandererEntity), alice);
  }

  function test_tokenOwner_notForCycleEntity() public {
    // cycleEntity shouldn't even be a token
    assertEq(ERC721Namespaces.WandererNFT.ownerOf(cycleEntity), address(0));
  }

  function test_activeGuise() public {
    assertEq(ActiveGuise.get(cycleEntity), guiseEntity);
    assertEq(ActiveGuise.get(wandererEntity), bytes32(0));
  }

  function test_experience() public {
    assertTrue(LibExperience.hasExp(cycleEntity));
    // TODO wandererEntity could have exp for some non-cycle-related reasons, come back to this later
    // TODO (same thing with currents, though less likely)
    assertFalse(LibExperience.hasExp(wandererEntity));
  }

  function test_currents() public {
    assertGt(LifeCurrent.get(cycleEntity), 0);
    assertGt(ManaCurrent.get(cycleEntity), 0);
  }

  function test_cycleTurns() public {
    assertGt(CycleTurns.getValue(cycleEntity), 0);
  }
}
