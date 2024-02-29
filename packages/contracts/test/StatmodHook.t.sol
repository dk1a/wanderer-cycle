// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { Statmod } from "../src/modules/statmod/Statmod.sol";
import { StatmodHook } from "../src/modules/statmod/StatmodHook.sol";
import { StatmodTopic, StatmodTopics } from "../src/modules/statmod/StatmodTopic.sol";
import { StatmodOp, EleStat } from "../src/codegen/common.sol";
import { StatmodOp_length, EleStat_length } from "../src/CustomTypes.sol";

contract StatmodHookTest is MudLibTest {
  bytes32 internal targetEntity = keccak256("targetEntity");

  // some statmod prototype entities and their topics
  StatmodTopic lifeTopic = StatmodTopics.LIFE;
  bytes32 addLifePE = StatmodTopics.LIFE.toStatmodEntity(StatmodOp.ADD, EleStat.NONE);
  bytes32 mulLifePE = StatmodTopics.LIFE.toStatmodEntity(StatmodOp.MUL, EleStat.NONE);
  bytes32 baddLifePE = StatmodTopics.LIFE.toStatmodEntity(StatmodOp.BADD, EleStat.NONE);

  StatmodTopic attackTopic = StatmodTopics.ATTACK;
  bytes32 mulPhysicalAttackPE = StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.MUL, EleStat.PHYSICAL);
  bytes32 mulFireAttackPE = StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.MUL, EleStat.FIRE);
  bytes32 addFireAttackPE = StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.ADD, EleStat.FIRE);
  bytes32 addColdAttackPE = StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.ADD, EleStat.COLD);

  // bytes32[] memory keyTuple = new bytes32[](2);
  // keyTuple[0] = keccak256("targetEntity");// Пример targetEntity
  // keyTuple[1] = keccak256("otherEntity"); // Пример baseEntity

  function setUp() public override {
    StatmodHook statmodHook = new StatmodHook();
    // Setup the StatmodHook contract
    // This might involve deploying other contracts that `StatmodHook` depends on and configuring them
  }

  function tearDown() public {
    // Clean up state if necessary
  }

  // function testHandleSet() public {
  // 	// Prepare the parameters for the `handleSet` function
  // 	bytes32[] memory keyTuple = new bytes32[](2);
  // 	keyTuple[0] = bytes32("targetEntity");
  // 	keyTuple[1] = bytes32("baseEntity");

  // 	// Call the function
  // 	StatmodHook.handleSet(keyTuple);

  // 	// Assert the expected state change happened
  // 	// This could involve checking if the item was correctly added to `StatmodIdxList` and `StatmodIdxMap`
  // 	// assertTrue(condition) or assertEq(value1, value2) can be used for assertions
  // }
}
