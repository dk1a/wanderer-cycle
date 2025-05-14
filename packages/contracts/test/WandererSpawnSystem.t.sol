// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { IERC721Errors } from "@latticexyz/world-modules/src/modules/erc721-puppet/IERC721Errors.sol";

import { BaseTest } from "./BaseTest.t.sol";
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";
import { hasKey } from "@latticexyz/world-modules/src/modules/keysintable/hasKey.sol";

import { Wanderer, GuisePrototype } from "../src/namespaces/root/codegen/index.sol";
import { LifeCurrent, ManaCurrent } from "../src/namespaces/charstat/codegen/index.sol";
import { ActiveCycle, ActiveGuise, CycleTurns } from "../src/namespaces/cycle/codegen/index.sol";

import { InitCycleSystem, initCycleSystem } from "../src/namespaces/cycle/codegen/systems/InitCycleSystemLib.sol";

import { LibGuise } from "../src/namespaces/root/guise/LibGuise.sol";
import { LibWheel } from "../src/namespaces/wheel/LibWheel.sol";
import { LibCycle } from "../src/namespaces/cycle/LibCycle.sol";
import { LibExperience } from "../src/namespaces/charstat/LibExperience.sol";
import { ERC721Namespaces } from "../src/namespaces/erc721-puppet/ERC721Namespaces.sol";

library PublicOwnerOfHelper {
  function ownerOf(uint256 tokenId) public view returns (address) {
    return ERC721Namespaces.Wanderer.tokenContract().ownerOf(tokenId);
  }
}

contract WandererSpawnSystemTest is BaseTest {
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
    defaultWheelEntity = LibWheel.getWheelEntity("Wheel of Attainment");
  }

  function testSetUpInvalidGuise() public {
    vm.prank(alice);
    vm.expectRevert(InitCycleSystem.InitCycleSystem_InvalidGuiseEntity.selector);
    world.spawnWanderer(keccak256("invalid guise"));
  }

  function testInitCycleAnother() public {
    // initializing a cycle for some unrelated entity should work fine and produce an unrelated cycleEntity
    bytes32 anotherCycleEntity = initCycleSystem.initCycle(getUniqueEntity(), guiseEntity, defaultWheelEntity);
    assertNotEq(anotherCycleEntity, cycleEntity);
  }

  function testEntities() public {
    assertNotEq(cycleEntity, wandererEntity);
    assertNotEq(cycleEntity, 0);
  }

  function testWanderer() public {
    assertTrue(Wanderer.get(wandererEntity));
  }

  function testTokenOwner() public {
    assertEq(ERC721Namespaces.Wanderer.tokenContract().ownerOf(uint256(wandererEntity)), alice);
    assertEq(ERC721Namespaces.Wanderer._ownerOf(uint256(wandererEntity)), alice);
  }

  function testTokenOwnerNotForCycleEntity() public {
    // cycleEntity shouldn't even be a token
    assertEq(ERC721Namespaces.Wanderer._ownerOf(uint256(cycleEntity)), address(0));
    vm.expectPartialRevert(IERC721Errors.ERC721NonexistentToken.selector);
    PublicOwnerOfHelper.ownerOf(uint256(cycleEntity));
  }

  function testActiveGuise() public {
    assertEq(ActiveGuise.get(cycleEntity), guiseEntity);
    assertEq(ActiveGuise.get(wandererEntity), bytes32(0));
  }

  function testExperience() public {
    assertTrue(LibExperience.hasExp(cycleEntity));
    // TODO wandererEntity could have exp for some non-cycle-related reasons, come back to this later
    // TODO (same thing with currents, though less likely)
    assertFalse(LibExperience.hasExp(wandererEntity));
  }

  function testCurrents() public {
    assertGt(LifeCurrent.get(cycleEntity), 0);
    assertGt(ManaCurrent.get(cycleEntity), 0);
  }

  function testCycleTurns() public {
    assertGt(CycleTurns.getValue(cycleEntity), 0);
  }
}
