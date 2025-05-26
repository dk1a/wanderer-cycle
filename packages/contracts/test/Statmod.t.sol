// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseTest } from "./BaseTest.t.sol";
import { StatmodBase } from "../src/namespaces/statmod/codegen/tables/StatmodBase.sol";
import { Statmod } from "../src/namespaces/statmod/Statmod.sol";
import { StatmodTopic, StatmodTopics } from "../src/namespaces/statmod/StatmodTopic.sol";
import { statmodName } from "../src/namespaces/statmod/statmodName.sol";
import { StatmodOp, EleStat } from "../src/codegen/common.sol";
import { StatmodOp_length, EleStat_length } from "../src/CustomTypes.sol";

contract StatmodTest is BaseTest {
  bytes32 internal targetEntity = keccak256("targetEntity");

  // some statmod prototype entities and their topics
  bytes32 lifeAddEntity;
  bytes32 lifeMulEntity;
  bytes32 lifeBaddEntity;
  bytes32 attackMulPhysicalEntity;
  bytes32 attackMulFireEntity;
  bytes32 attackAddFireEntity;
  bytes32 attackAddColdEntity;

  function setUp() public virtual override {
    super.setUp();

    lifeAddEntity = StatmodTopics.LIFE.toStatmodEntity(StatmodOp.ADD, EleStat.NONE);
    lifeMulEntity = StatmodTopics.LIFE.toStatmodEntity(StatmodOp.MUL, EleStat.NONE);
    lifeBaddEntity = StatmodTopics.LIFE.toStatmodEntity(StatmodOp.BADD, EleStat.NONE);
    attackMulPhysicalEntity = StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.MUL, EleStat.PHYSICAL);
    attackMulFireEntity = StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.MUL, EleStat.FIRE);
    attackAddFireEntity = StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.ADD, EleStat.FIRE);
    attackAddColdEntity = StatmodTopics.ATTACK.toStatmodEntity(StatmodOp.ADD, EleStat.COLD);
  }

  function testStatmodNames() public {
    // check that the statmod names are generated correctly
    assertEq(statmodName(StatmodBase.get(lifeAddEntity)), "+# life");
    assertEq(statmodName(StatmodBase.get(lifeMulEntity)), "#% increased life");
    assertEq(statmodName(StatmodBase.get(lifeBaddEntity)), "+# base life");

    assertEq(statmodName(StatmodBase.get(attackMulPhysicalEntity)), "#% increased physical attack");
    assertEq(statmodName(StatmodBase.get(attackMulFireEntity)), "#% increased fire attack");
    assertEq(statmodName(StatmodBase.get(attackAddFireEntity)), "+# fire attack");
    assertEq(statmodName(StatmodBase.get(attackAddColdEntity)), "+# cold attack");
  }

  function testGetValuesParallelChanges() public {
    // a bunch of changes to make sure they don't interfere with each other
    Statmod.increase(targetEntity, lifeMulEntity, 11);

    Statmod.increase(targetEntity, lifeAddEntity, 80);

    Statmod.decrease(targetEntity, lifeMulEntity, 2);

    Statmod.decrease(targetEntity, lifeAddEntity, 10);

    Statmod.increase(targetEntity, lifeMulEntity, 1);

    Statmod.increase(targetEntity, lifeBaddEntity, 54);
    Statmod.decrease(targetEntity, lifeBaddEntity, 27);

    Statmod.increase(targetEntity, lifeMulEntity, 2);
    Statmod.increase(targetEntity, lifeMulEntity, 5);

    // (10 + 27) * (100 + 17) / 100 + 70
    uint32[StatmodOp_length] memory result = Statmod.getValues(targetEntity, StatmodTopics.LIFE, 10);
    assertEq(result[uint256(StatmodOp.BADD)], 37);
    assertEq(result[uint256(StatmodOp.MUL)], 43);
    assertEq(result[uint256(StatmodOp.ADD)], 113);
  }

  function testGetValuesFinal() public {
    Statmod.increase(targetEntity, lifeBaddEntity, 27);
    Statmod.increase(targetEntity, lifeMulEntity, 17);
    Statmod.increase(targetEntity, lifeAddEntity, 70);

    // (10 + 27) * (100 + 17) / 100 + 70
    uint32 result = Statmod.getValuesFinal(targetEntity, StatmodTopics.LIFE, 10);
    assertEq(result, 113);
  }

  function testGetValuesElementalFinal() public {
    Statmod.increase(targetEntity, attackMulPhysicalEntity, 40);
    Statmod.increase(targetEntity, attackAddFireEntity, 100);
    Statmod.increase(targetEntity, attackMulFireEntity, 40);
    Statmod.increase(targetEntity, attackAddColdEntity, 50);

    uint32[EleStat_length] memory result = Statmod.getValuesElementalFinal(
      targetEntity,
      StatmodTopics.ATTACK,
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
