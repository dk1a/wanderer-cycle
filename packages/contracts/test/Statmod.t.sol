// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { Statmod } from "../src/modules/statmod/Statmod.sol";
import { StatmodTopic, StatmodTopics } from "../src/modules/statmod/StatmodTopic.sol";
import { StatmodOp, EleStat } from "../src/codegen/common.sol";
import { StatmodOp_length, EleStat_length } from "../src/CustomTypes.sol";

contract StatmodTest is MudLibTest {
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

  function setUp() public override {
    super.setUp();
  }

  function test_statmod_getValues_parallelChanges() public {
    // a bunch of changes to make sure they don't interfere with each other
    Statmod.increase(targetEntity, mulLifePE, 11);

    Statmod.increase(targetEntity, addLifePE, 80);

    Statmod.decrease(targetEntity, mulLifePE, 2);

    Statmod.decrease(targetEntity, addLifePE, 10);

    Statmod.increase(targetEntity, mulLifePE, 1);

    Statmod.increase(targetEntity, baddLifePE, 54);
    Statmod.decrease(targetEntity, baddLifePE, 27);

    Statmod.increase(targetEntity, mulLifePE, 2);
    Statmod.increase(targetEntity, mulLifePE, 5);

    // (10 + 27) * (100 + 17) / 100 + 70
    uint32[StatmodOp_length] memory result = Statmod.getValues(targetEntity, lifeTopic, 10);
    assertEq(result[uint256(StatmodOp.BADD)], 37);
    assertEq(result[uint256(StatmodOp.MUL)], 43);
    assertEq(result[uint256(StatmodOp.ADD)], 113);
  }

  function test_statmod_getValuesFinal() public {
    Statmod.increase(targetEntity, baddLifePE, 27);
    Statmod.increase(targetEntity, mulLifePE, 17);
    Statmod.increase(targetEntity, addLifePE, 70);

    // (10 + 27) * (100 + 17) / 100 + 70
    uint32 result = Statmod.getValuesFinal(targetEntity, lifeTopic, 10);
    assertEq(result, 113);
  }

  function test_statmod_getValuesElementalFinal() public {
    Statmod.increase(targetEntity, mulPhysicalAttackPE, 40);
    Statmod.increase(targetEntity, addFireAttackPE, 100);
    Statmod.increase(targetEntity, mulFireAttackPE, 40);
    Statmod.increase(targetEntity, addColdAttackPE, 50);

    uint32[EleStat_length] memory result = Statmod.getValuesElementalFinal(
      targetEntity,
      attackTopic,
      [uint32(0), 200, 300, 400, 500]
    );

    uint32[EleStat_length] memory expected;
    expected[uint256(EleStat.NONE)] = 0;
    expected[uint256(EleStat.PHYSICAL)] = 280;
    expected[uint256(EleStat.FIRE)] = 520;
    expected[uint256(EleStat.COLD)] = 450;
    expected[uint256(EleStat.POISON)] = 500;

    for (uint256 el; el < EleStat_length; el++) {
      assertEq(result[el], expected[el]);
    }
  }
}
