// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Vm } from "@prb/test/src/Vm.sol";

import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { StrSlice, toSlice } from "@dk1a/solidity-stringutils/src/StrSlice.sol";

import { Topics, Topic } from "../charstat/Topics.sol";
import { PStat } from "../charstat/ExperienceComponent.sol";

import { StatmodInitSystem, ID as StatmodInitSystemID } from "../statmod/StatmodInitSystem.sol";
import { StatmodPrototype, Op, Element } from "../statmod/StatmodPrototypeComponent.sol";
import { statmodName } from "../statmod/utils.sol";

using { toSlice } for string;

library LibInitStatmod {
  function initialize(IWorld world) internal {
    // primary stats
    for (uint256 i; i < Topics.PSTAT().length; i++) {
      _add(world, Topics.PSTAT()[i], Op.MUL);
      _add(world, Topics.PSTAT()[i], Op.ADD);
    }

    // secondary stats
    _add(world, Topics.FORTUNE, Op.MUL);
    _add(world, Topics.FORTUNE, Op.ADD);

    _add(world, Topics.CONNECTION, Op.MUL);
    _add(world, Topics.CONNECTION, Op.ADD);

    // currents
    _add(world, Topics.LIFE, Op.MUL);
    _add(world, Topics.LIFE, Op.ADD);
    _add(world, Topics.LIFE, Op.BADD);

    _add(world, Topics.MANA, Op.MUL);
    _add(world, Topics.MANA, Op.ADD);
    _add(world, Topics.MANA, Op.BADD);

    // currents gained per turn
    _add(world, Topics.LIFE_GAINED_PER_TURN, Op.ADD);
    _add(world, Topics.MANA_GAINED_PER_TURN, Op.ADD);

    // attack
    _add(world, Topics.ATTACK, Op.BADD, Element.PHYSICAL);

    _add(world, Topics.ATTACK, Op.MUL);

    _add(world, Topics.ATTACK, Op.MUL, Element.FIRE);
    _add(world, Topics.ATTACK, Op.MUL, Element.COLD);

    _add(world, Topics.ATTACK, Op.ADD, Element.PHYSICAL);
    _add(world, Topics.ATTACK, Op.ADD, Element.FIRE);
    _add(world, Topics.ATTACK, Op.ADD, Element.COLD);
    _add(world, Topics.ATTACK, Op.ADD, Element.POISON);

    // attack special
    _add(world, Topics.PERCENT_OF_MISSING_LIFE_TO_ATTACK, Op.ADD, Element.PHYSICAL);

    // spell
    _add(world, Topics.SPELL, Op.MUL);

    _add(world, Topics.SPELL, Op.ADD, Element.PHYSICAL);
    _add(world, Topics.SPELL, Op.ADD, Element.FIRE);
    _add(world, Topics.SPELL, Op.ADD, Element.COLD);

    // resistance
    _add(world, Topics.RESISTANCE, Op.ADD, Element.PHYSICAL);
    _add(world, Topics.RESISTANCE, Op.ADD, Element.FIRE);
    _add(world, Topics.RESISTANCE, Op.ADD, Element.COLD);
    _add(world, Topics.RESISTANCE, Op.ADD, Element.POISON);

    // damage taken per round
    _add(world, Topics.DAMAGE_TAKEN_PER_ROUND, Op.ADD, Element.PHYSICAL);
    _add(world, Topics.DAMAGE_TAKEN_PER_ROUND, Op.ADD, Element.FIRE);
    _add(world, Topics.DAMAGE_TAKEN_PER_ROUND, Op.ADD, Element.COLD);
    _add(world, Topics.DAMAGE_TAKEN_PER_ROUND, Op.ADD, Element.POISON);

    // debuffs
    _add(world, Topics.DAMAGE_TAKEN, Op.MUL);
    _add(world, Topics.REDUCED_DAMAGE_DONE, Op.ADD);
    _add(world, Topics.ROUNDS_STUNNED, Op.ADD);

    // level
    _add(world, Topics.LEVEL, Op.BADD);
  }

  function _add(
    IWorld world,
    Topic topic,
    Op op
  ) internal {
    _add(world, topic, op, Element.ALL);
  }

  function _add(
    IWorld world,
    Topic topic,
    Op op,
    Element element
  ) internal {
    StatmodInitSystem system
      = StatmodInitSystem(getAddressById(world.systems(), StatmodInitSystemID));

    system.executeTyped(
      StatmodPrototype({
        topicEntity: topic.toEntity(),
        op: op,
        element: element
      })
    );
  }
}