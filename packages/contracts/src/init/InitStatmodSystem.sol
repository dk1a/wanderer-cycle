// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { Topics, Topic } from "../charstat/Topics.sol";
import { statmodName } from "../statmod/statmodName.sol";
import {
  getStatmodProtoEntity,
  Op, Element,
  StatmodPrototype,
  StatmodPrototypeComponent,
  ID as StatmodPrototypeComponentID
} from "../statmod/StatmodPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

uint256 constant ID = uint256(keccak256("system.InitStatmod"));

contract InitStatmodSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory) public override onlyOwner returns (bytes memory) {
    // primary stats
    for (uint256 i; i < Topics.PSTAT().length; i++) {
      add(Topics.PSTAT()[i], Op.MUL);
      add(Topics.PSTAT()[i], Op.ADD);
    }

    // secondary stats
    add(Topics.FORTUNE, Op.MUL);
    add(Topics.FORTUNE, Op.ADD);

    add(Topics.CONNECTION, Op.MUL);
    add(Topics.CONNECTION, Op.ADD);

    // currents
    add(Topics.LIFE, Op.MUL);
    add(Topics.LIFE, Op.ADD);
    add(Topics.LIFE, Op.BADD);

    add(Topics.MANA, Op.MUL);
    add(Topics.MANA, Op.ADD);
    add(Topics.MANA, Op.BADD);

    // currents gained per turn
    add(Topics.LIFE_GAINED_PER_TURN, Op.ADD);
    add(Topics.MANA_GAINED_PER_TURN, Op.ADD);

    // attack
    add(Topics.ATTACK, Op.BADD, Element.PHYSICAL);

    add(Topics.ATTACK, Op.MUL);

    add(Topics.ATTACK, Op.MUL, Element.FIRE);
    add(Topics.ATTACK, Op.MUL, Element.COLD);

    add(Topics.ATTACK, Op.ADD, Element.PHYSICAL);
    add(Topics.ATTACK, Op.ADD, Element.FIRE);
    add(Topics.ATTACK, Op.ADD, Element.COLD);
    add(Topics.ATTACK, Op.ADD, Element.POISON);

    // attack special
    add(Topics.PERCENT_OF_MISSING_LIFE_TO_ATTACK, Op.ADD, Element.PHYSICAL);

    // spell
    add(Topics.SPELL, Op.MUL);

    add(Topics.SPELL, Op.ADD, Element.PHYSICAL);
    add(Topics.SPELL, Op.ADD, Element.FIRE);
    add(Topics.SPELL, Op.ADD, Element.COLD);

    // resistance
    add(Topics.RESISTANCE, Op.ADD, Element.PHYSICAL);
    add(Topics.RESISTANCE, Op.ADD, Element.FIRE);
    add(Topics.RESISTANCE, Op.ADD, Element.COLD);
    add(Topics.RESISTANCE, Op.ADD, Element.POISON);

    // damage taken per round
    add(Topics.DAMAGE_TAKEN_PER_ROUND, Op.ADD, Element.PHYSICAL);
    add(Topics.DAMAGE_TAKEN_PER_ROUND, Op.ADD, Element.FIRE);
    add(Topics.DAMAGE_TAKEN_PER_ROUND, Op.ADD, Element.COLD);
    add(Topics.DAMAGE_TAKEN_PER_ROUND, Op.ADD, Element.POISON);

    // debuffs
    add(Topics.DAMAGE_TAKEN, Op.MUL);
    add(Topics.REDUCED_DAMAGE_DONE, Op.ADD);
    add(Topics.ROUNDS_STUNNED, Op.ADD);

    // level
    add(Topics.LEVEL, Op.BADD);

    return '';
  }

  function add(
    Topic topic,
    Op op
  ) internal {
    add(topic, op, Element.ALL);
  }

  function add(
    Topic topic,
    Op op,
    Element element
  ) internal {
    add(
      StatmodPrototype({
        topicEntity: topic.toEntity(),
        op: op,
        element: element
      })
    );
  }

  function add(
    StatmodPrototype memory prototype
  ) internal {
    StatmodPrototypeComponent protoComp
      = StatmodPrototypeComponent(getAddressById(components, StatmodPrototypeComponentID));
    NameComponent nameComp
      = NameComponent(getAddressById(components, NameComponentID));

    uint256 protoEntity = getStatmodProtoEntity(prototype);
    protoComp.set(protoEntity, prototype);

    string memory name = statmodName(world, prototype.topicEntity, prototype.op, prototype.element);
    nameComp.set(protoEntity, name);
  }
}