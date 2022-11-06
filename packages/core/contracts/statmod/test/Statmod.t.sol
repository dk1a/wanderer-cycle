// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Test } from "../../Test.sol";

import { World } from "solecs/World.sol";

import { StatmodPrototypeComponent } from "../StatmodPrototypeComponent.sol";
import { StatmodPrototypeExtComponent } from "../StatmodPrototypeExtComponent.sol";
import { StatmodScopeComponent } from "../StatmodScopeComponent.sol";
import { StatmodValueComponent } from "../StatmodValueComponent.sol";

import { Statmod } from "../Statmod.sol";
import {
  StatmodPrototype,
  Op, OP_L, OP_FINAL,
  Element, EL_L
} from "../StatmodPrototypeComponent.sol";

contract StatmodTest is Test {
  using Statmod for Statmod.Self;

  World world;
  StatmodPrototypeComponent prototypeComponent;
  StatmodPrototypeExtComponent prototypeExtComponent;
  StatmodScopeComponent scopeComponent;
  StatmodValueComponent valueComponent;

  // this should normally be an in-memory object, it's in storage for testing convenience
  Statmod.Self _statmod;

  uint256 mainEntity = uint256(keccak256('mainEntity'));

  // statmod prototype entities and their topics
  bytes4 lifeTopic = bytes4(keccak256('life'));
  uint256 addLifeProtoEntity = uint256(keccak256('+# life'));
  uint256 mulLifeProtoEntity = uint256(keccak256('#% increased life'));
  uint256 baddLlifeProtoEntity = uint256(keccak256('+# to base life'));

  bytes4 attackTopic = bytes4(keccak256('attack'));
  uint256 mulAttackProtoEntity = uint256(keccak256('#% increased attack'));
  uint256 fireAttackProtoEntity = uint256(keccak256('+# fire attack'));
  uint256 mulFireAttackProtoEntity = uint256(keccak256('#% increased fire attack'));
  uint256 coldAttackProtoEntity = uint256(keccak256('+# cold attack'));

  function setUp() public virtual {
    // deploy world
    world = new World();
    world.init();

    // deploy components
    prototypeComponent = new StatmodPrototypeComponent(address(world));
    prototypeExtComponent = new StatmodPrototypeExtComponent(address(world));
    scopeComponent = new StatmodScopeComponent(address(world));
    valueComponent = new StatmodValueComponent(address(world));

    // init library's object
    _statmod = Statmod.__construct(
      world.components(),
      mainEntity
    );

    // init prototypes
    // life
    prototypeComponent.set(addLifeProtoEntity, StatmodPrototype({
      topic: lifeTopic,
      op: Op.ADD,
      element: Element.ALL
    }));
    prototypeComponent.set(mulLifeProtoEntity, StatmodPrototype({
      topic: lifeTopic,
      op: Op.MUL,
      element: Element.ALL
    }));
    prototypeComponent.set(baddLlifeProtoEntity, StatmodPrototype({
      topic: lifeTopic,
      op: Op.BADD,
      element: Element.ALL
    }));
    // attack
    prototypeComponent.set(mulAttackProtoEntity, StatmodPrototype({
      topic: attackTopic,
      op: Op.MUL,
      element: Element.ALL
    }));
    prototypeComponent.set(fireAttackProtoEntity, StatmodPrototype({
      topic: attackTopic,
      op: Op.ADD,
      element: Element.FIRE
    }));
    prototypeComponent.set(mulFireAttackProtoEntity, StatmodPrototype({
      topic: attackTopic,
      op: Op.MUL,
      element: Element.FIRE
    }));
    prototypeComponent.set(coldAttackProtoEntity, StatmodPrototype({
      topic: attackTopic,
      op: Op.ADD,
      element: Element.COLD
    }));
  }

  function testGetValues() public {
    // a bunch of changes to make sure they don't interfere with each other
    _statmod.increase(mulLifeProtoEntity, 11);

    _statmod.increase(addLifeProtoEntity, 80);

    _statmod.decrease(mulLifeProtoEntity, 2);

    _statmod.decrease(addLifeProtoEntity, 10);

    _statmod.increase(mulLifeProtoEntity, 1);

    _statmod.increase(baddLlifeProtoEntity, 54);
    _statmod.decrease(baddLlifeProtoEntity, 27);

    _statmod.increase(mulLifeProtoEntity, 2);
    _statmod.increase(mulLifeProtoEntity, 5);

    // (10 + 27) * (100 + 17) / 100 + 70
    uint32[OP_L] memory result = _statmod.getValues(lifeTopic, 10);
    assertEq(result[uint256(Op.BADD)], 37);
    assertEq(result[uint256(Op.MUL)], 43);
    assertEq(result[uint256(Op.ADD)], 113);
  }

  function testGetValuesFinal() public {
    _statmod.increase(baddLlifeProtoEntity, 27);
    _statmod.increase(mulLifeProtoEntity, 17);
    _statmod.increase(addLifeProtoEntity, 70);

    // (10 + 27) * (100 + 17) / 100 + 70
    uint32 result = _statmod.getValuesFinal(lifeTopic, 10);
    assertEq(result, 113);
  }

  function testGetValuesElemental() public {
    _statmod.increase(mulAttackProtoEntity, 40);
    _statmod.increase(fireAttackProtoEntity, 100);
    _statmod.increase(mulFireAttackProtoEntity, 40);
    _statmod.increase(coldAttackProtoEntity, 50);
    
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
    _statmod.increase(mulAttackProtoEntity, 40);
    _statmod.increase(fireAttackProtoEntity, 100);
    _statmod.increase(mulFireAttackProtoEntity, 40);
    _statmod.increase(coldAttackProtoEntity, 50);
    
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