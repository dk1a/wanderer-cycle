// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";

import { Statmod } from "../src/statmod/Statmod.sol";
import { StatmodTopic, StatmodTopics } from "../src/statmod/StatmodTopic.sol";
import { StatmodOp, EleStat } from "../src/codegen/common.sol";
import { StatmodOp_length, EleStat_length, StatmodOpFinal } from "../src/CustomTypes.sol";
/*
contract StatmodTest is MudLibTest {
  // some statmod prototype entities and their topics
  StatmodTopic lifeTopic = StatmodTopics.LIFE;
  uint256 addLifePE = StatmodTopics.LIFE.toStatmodEntity(Op.ADD, Element.ALL);
  uint256 mulLifePE = StatmodTopics.LIFE.toStatmodEntity(Op.MUL, Element.ALL);
  uint256 baddLifePE = StatmodTopics.LIFE.toStatmodEntity(Op.BADD, Element.ALL);

  StatmodTopic attackTopic = Topics.ATTACK;
  uint256 mulAttackPE = Topics.ATTACK.toStatmodEntity(Op.MUL, Element.ALL);
  uint256 mulFireAttackPE = Topics.ATTACK.toStatmodEntity(Op.MUL, Element.FIRE);
  uint256 addFireAttackPE = Topics.ATTACK.toStatmodEntity(Op.ADD, Element.FIRE);
  uint256 addColdAttackPE = Topics.ATTACK.toStatmodEntity(Op.ADD, Element.COLD);

  function setUp() public override {
    super.setUp();

    // init library's object
    _statmod = Statmod.__construct(
      world.components(),
      uint256(keccak256('mainEntity'))
    );
  }

  function test_statmod_getValues_parallelChanges() public {
    // a bunch of changes to make sure they don't interfere with each other
    _statmod.increase(mulLifePE, 11);

    _statmod.increase(addLifePE, 80);

    _statmod.decrease(mulLifePE, 2);

    _statmod.decrease(addLifePE, 10);

    _statmod.increase(mulLifePE, 1);

    _statmod.increase(baddLifePE, 54);
    _statmod.decrease(baddLifePE, 27);

    _statmod.increase(mulLifePE, 2);
    _statmod.increase(mulLifePE, 5);

    // (10 + 27) * (100 + 17) / 100 + 70
    uint32[OP_L] memory result = _statmod.getValues(lifeTopic, 10);
    assertEq(result[uint256(Op.BADD)], 37);
    assertEq(result[uint256(Op.MUL)], 43);
    assertEq(result[uint256(Op.ADD)], 113);
  }

  function test_statmod_getValuesFinal() public {
    _statmod.increase(baddLifePE, 27);
    _statmod.increase(mulLifePE, 17);
    _statmod.increase(addLifePE, 70);

    // (10 + 27) * (100 + 17) / 100 + 70
    uint32 result = _statmod.getValuesFinal(lifeTopic, 10);
    assertEq(result, 113);
  }

  function test_statmod_getValuesElementalFinal() public {
    _statmod.increase(mulAttackPE, 40);
    _statmod.increase(addFireAttackPE, 100);
    _statmod.increase(mulFireAttackPE, 40);
    _statmod.increase(addColdAttackPE, 50);
    
    uint32[EL_L] memory result
      = _statmod.getValuesElementalFinal(attackTopic, [uint32(0), 200, 300, 400, 500]);

    uint32[EL_L] memory expected;
    expected[uint256(Element.ALL)] = 0;
    expected[uint256(Element.PHYSICAL)] = 280;
    expected[uint256(Element.FIRE)] = 640;
    expected[uint256(Element.COLD)] = 610;
    expected[uint256(Element.POISON)] = 700;

    for (uint256 el; el < EL_L; el++) {
      assertEq(result[el], expected[el]);
    }
  }

  // TODO Element.ALL is confusing and useless. You should replace it with NONE and make this test obsolete
  function test_statmod_getValuesElemental_withBaseAll() public {
    _statmod.increase(mulAttackPE, 40);
    _statmod.increase(addFireAttackPE, 100);
    _statmod.increase(mulFireAttackPE, 40);
    _statmod.increase(addColdAttackPE, 50);
    
    uint32[EL_L] memory result
      = _statmod.getValuesElementalFinal(attackTopic, [uint32(100), 200, 300, 400, 500]);

    uint32[EL_L] memory expected;
    expected[uint256(Element.ALL)] = 140;
    expected[uint256(Element.PHYSICAL)] = 420;
    expected[uint256(Element.FIRE)] = 820;
    expected[uint256(Element.COLD)] = 750;
    expected[uint256(Element.POISON)] = 840;

    for (uint256 el; el < EL_L; el++) {
      assertEq(result[el], expected[el]);
    }
  }
}
*/
