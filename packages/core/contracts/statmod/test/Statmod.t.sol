// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Test } from "../../Test.sol";

import { Statmod } from "../Statmod.sol";
import {
  Op, OP_L, OP_FINAL,
  Element, EL_L
} from "../StatmodPrototypeComponent.sol";

contract StatmodTest is Test {
  using Statmod for Statmod.Self;

  // this should normally be an in-memory object, it's in storage for testing convenience
  Statmod.Self _statmod;

  // some statmod prototype entities and their topics
  bytes4 lifeTopic = bytes4(keccak256('life'));
  uint256 addLifePE = uint256(keccak256('+# life'));
  uint256 mulLifePE = uint256(keccak256('#% increased life'));
  uint256 baddLifePE = uint256(keccak256('+# base life'));

  bytes4 attackTopic = bytes4(keccak256('attack'));
  uint256 mulAttackPE = uint256(keccak256('#% increased attack'));
  uint256 mulFireAttackPE = uint256(keccak256('#% increased fire attack'));
  uint256 addFireAttackPE = uint256(keccak256('+# fire to attack'));
  uint256 addColdAttackPE = uint256(keccak256('+# cold to attack'));

  function setUp() public override {
    super.setUp();

    // init library's object
    _statmod = Statmod.__construct(
      world.components(),
      uint256(keccak256('mainEntity'))
    );
  }

  function testGetValues() public {
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

  function testGetValuesFinal() public {
    _statmod.increase(baddLifePE, 27);
    _statmod.increase(mulLifePE, 17);
    _statmod.increase(addLifePE, 70);

    // (10 + 27) * (100 + 17) / 100 + 70
    uint32 result = _statmod.getValuesFinal(lifeTopic, 10);
    assertEq(result, 113);
  }

  function testGetValuesElemental() public {
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

  function testGetValuesElementalWithBaseAll() public {
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