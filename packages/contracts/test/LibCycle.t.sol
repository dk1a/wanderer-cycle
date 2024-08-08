// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { ActiveCycle, CycleTurns, CycleToWanderer } from "../src/codegen/index.sol";

import { PassCycleTurnSystem } from "../src/cycle/PassCycleTurnSystem.sol";

import { LibGuise } from "../src/guise/LibGuise.sol";
import { LibCycle } from "../src/cycle/LibCycle.sol";
import { LibCycleTurns } from "../src/cycle/LibCycleTurns.sol";

contract LibCycleTest is MudLibTest {
  bytes32 internal wandererEntity;
  bytes32 internal guiseProtoEntity;
  bytes32 internal wheelEntity;
  bytes32 internal cycleEntity;

  function setUp() public virtual override {
    super.setUp();
    // Initialize with test data
    wandererEntity = keccak256("wandererEntity");
    wheelEntity = keccak256("wheelEntity");

    guiseProtoEntity = LibGuise.getGuiseEntity("Warrior");

    // Simulate existing cycle entity
    cycleEntity = LibCycle.initCycle(wandererEntity, guiseProtoEntity, wheelEntity);
  }

  function testInitCycle() public {
    assertEq(cycleEntity, ActiveCycle.get(wandererEntity));
  }

  function testPassCycle() public {
    world.passCycle(wandererEntity);

    uint32 turns = CycleTurns.get(cycleEntity);
    assertEq(turns, LibCycleTurns.TURNS_PER_PERIOD - 1);
  }

  function testEndCycle() public {
    LibCycle.endCycle(wandererEntity, cycleEntity);
    assertEq(ActiveCycle.get(wandererEntity), bytes32(0));
    assertEq(CycleToWanderer.get(cycleEntity), bytes32(0));
  }

  function testGetCycleEntityPermissioned() public {
    bytes32 retrievedCycleEntity = LibCycle.getCycleEntityPermissioned(wandererEntity);
    assertEq(retrievedCycleEntity, cycleEntity);
  }
}
