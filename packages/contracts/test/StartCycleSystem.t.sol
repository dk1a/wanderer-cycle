// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { ActiveCycle } from "../src/codegen/index.sol";

import { LibGuise } from "../src/guise/LibGuise.sol";

contract StartCycleSystemTest is MudLibTest {
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
  }

  function testStartCycle() public {
    cycleEntity = world.startCycle(wandererEntity, guiseProtoEntity, wheelEntity);

    assertEq(cycleEntity, ActiveCycle.get(wandererEntity));
  }
}
