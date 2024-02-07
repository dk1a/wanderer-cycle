// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

//import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";
//
//import { Wheel, DefaultWheel, Name, WheelData } from "../codegen/index.sol";
//
//import { IWorld } from "solecs/interfaces/IWorld.sol";
//import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
//import { getAddressById } from "solecs/utils.sol";
//
//import { Topics, Topic } from "../charstat/Topics.sol";
//import { statmodName } from "../statmod/statmodName.sol";
//import { getStatmodProtoEntity, Op, Element, StatmodPrototype, StatmodPrototypeComponent, ID as StatmodPrototypeComponentID } from "../statmod/StatmodPrototypeComponent.sol";
//import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";
//import { ReverseHashNameComponent, ID as ReverseHashNameComponentID } from "../common/ReverseHashNameComponent.sol";
//
//library LibInitStatmod {
//  struct Comps {
//    StatmodPrototypeComponent proto;
//    NameComponent name;
//    ReverseHashNameComponent rhName;
//  }
//
//  function getComps(IUint256Component components) internal view returns (Comps memory result) {
//    result.proto = StatmodPrototypeComponent(getAddressById(components, StatmodPrototypeComponentID));
//    result.name = NameComponent(getAddressById(components, NameComponentID));
//    result.rhName = ReverseHashNameComponent(getAddressById(components, ReverseHashNameComponentID));
//  }
//
//  function init(IWorld world) internal {
//    Comps memory comps = getComps(world.components());
//
//    // primary stats
//    for (uint256 i; i < Topics.PSTAT().length; i++) {
//      add(comps, Topics.PSTAT()[i], Op.MUL);
//      add(comps, Topics.PSTAT()[i], Op.ADD);
//    }
//
//    // secondary stats
//    add(comps, Topics.FORTUNE, Op.MUL);
//    add(comps, Topics.FORTUNE, Op.ADD);
//
//    add(comps, Topics.CONNECTION, Op.MUL);
//    add(comps, Topics.CONNECTION, Op.ADD);
//
//    // currents
//    add(comps, Topics.LIFE, Op.MUL);
//    add(comps, Topics.LIFE, Op.ADD);
//    add(comps, Topics.LIFE, Op.BADD);
//
//    add(comps, Topics.MANA, Op.MUL);
//    add(comps, Topics.MANA, Op.ADD);
//    add(comps, Topics.MANA, Op.BADD);
//
//    // currents gained per turn
//    add(comps, Topics.LIFE_GAINED_PER_TURN, Op.ADD);
//    add(comps, Topics.MANA_GAINED_PER_TURN, Op.ADD);
//
//    // attack
//    add(comps, Topics.ATTACK, Op.BADD, Element.PHYSICAL);
//
//    add(comps, Topics.ATTACK, Op.MUL);
//
//    add(comps, Topics.ATTACK, Op.MUL, Element.FIRE);
//    add(comps, Topics.ATTACK, Op.MUL, Element.COLD);
//
//    add(comps, Topics.ATTACK, Op.ADD, Element.PHYSICAL);
//    add(comps, Topics.ATTACK, Op.ADD, Element.FIRE);
//    add(comps, Topics.ATTACK, Op.ADD, Element.COLD);
//    add(comps, Topics.ATTACK, Op.ADD, Element.POISON);
//
//    // attack special
//    add(comps, Topics.PERCENT_OF_MISSING_LIFE_TO_ATTACK, Op.ADD, Element.PHYSICAL);
//
//    // spell
//    add(comps, Topics.SPELL, Op.MUL);
//
//    add(comps, Topics.SPELL, Op.ADD, Element.PHYSICAL);
//    add(comps, Topics.SPELL, Op.ADD, Element.FIRE);
//    add(comps, Topics.SPELL, Op.ADD, Element.COLD);
//
//    // resistance
//    add(comps, Topics.RESISTANCE, Op.ADD, Element.PHYSICAL);
//    add(comps, Topics.RESISTANCE, Op.ADD, Element.FIRE);
//    add(comps, Topics.RESISTANCE, Op.ADD, Element.COLD);
//    add(comps, Topics.RESISTANCE, Op.ADD, Element.POISON);
//
//    // damage taken per round
//    add(comps, Topics.DAMAGE_TAKEN_PER_ROUND, Op.ADD, Element.PHYSICAL);
//    add(comps, Topics.DAMAGE_TAKEN_PER_ROUND, Op.ADD, Element.FIRE);
//    add(comps, Topics.DAMAGE_TAKEN_PER_ROUND, Op.ADD, Element.COLD);
//    add(comps, Topics.DAMAGE_TAKEN_PER_ROUND, Op.ADD, Element.POISON);
//
//    // debuffs
//    add(comps, Topics.DAMAGE_TAKEN, Op.MUL);
//    add(comps, Topics.REDUCED_DAMAGE_DONE, Op.ADD);
//    add(comps, Topics.ROUNDS_STUNNED, Op.ADD);
//
//    // level
//    add(comps, Topics.LEVEL, Op.BADD);
//  }
//
//  function add(Comps memory comps, Topic topic, Op op) internal {
//    add(comps, topic, op, Element.ALL);
//  }
//
//  function _add(Comps memory comps, Topic topic, Op op, Element element) internal {
//    add(comps, StatmodPrototype({ topicEntity: topic.toEntity(), op: op, element: element }));
//  }
//
//  function _add(Comps memory comps, StatmodPrototype memory prototype) internal {
//    uint256 protoEntity = getStatmodProtoEntity(prototype);
//    comps.proto.set(protoEntity, prototype);
//
//    string memory name = statmodName(comps.rhName, prototype.topicEntity, prototype.op, prototype.element);
//    comps.name.set(protoEntity, name);
//  }
//}
