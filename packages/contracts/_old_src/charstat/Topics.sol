// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";

import { PS_L, PStat } from "./LibExperience.sol";
import { statmodName } from "../statmod/statmodName.sol";
import { Op, Element, StatmodPrototype, getStatmodProtoEntity } from "../statmod/StatmodPrototypeComponent.sol";

type Topic is uint256;

library Topics {
  Topic constant STRENGTH = Topic.wrap(uint256(keccak256("strength")));
  Topic constant ARCANA = Topic.wrap(uint256(keccak256("arcana")));
  Topic constant DEXTERITY = Topic.wrap(uint256(keccak256("dexterity")));

  // pstat topics also come as an array since it's often useful to iterate them
  function PSTAT() internal pure returns (Topic[PS_L] memory r) {
    r[uint256(PStat.STRENGTH)] = STRENGTH;
    r[uint256(PStat.ARCANA)] = ARCANA;
    r[uint256(PStat.DEXTERITY)] = DEXTERITY;
  }

  Topic constant LIFE = Topic.wrap(uint256(keccak256("life")));
  Topic constant MANA = Topic.wrap(uint256(keccak256("mana")));
  Topic constant FORTUNE = Topic.wrap(uint256(keccak256("fortune")));
  Topic constant CONNECTION = Topic.wrap(uint256(keccak256("connection")));
  Topic constant LIFE_GAINED_PER_TURN = Topic.wrap(uint256(keccak256("life gained per turn")));
  Topic constant MANA_GAINED_PER_TURN = Topic.wrap(uint256(keccak256("mana gained per turn")));

  Topic constant ATTACK = Topic.wrap(uint256(keccak256("attack")));
  Topic constant SPELL = Topic.wrap(uint256(keccak256("spell")));
  Topic constant RESISTANCE = Topic.wrap(uint256(keccak256("resistance")));

  Topic constant DAMAGE_TAKEN_PER_ROUND = Topic.wrap(uint256(keccak256("damage taken per round")));

  Topic constant DAMAGE_TAKEN = Topic.wrap(uint256(keccak256("damage taken")));
  Topic constant REDUCED_DAMAGE_DONE = Topic.wrap(uint256(keccak256("reduced damage done")));
  Topic constant ROUNDS_STUNNED = Topic.wrap(uint256(keccak256("rounds stunned")));

  Topic constant PERCENT_OF_MISSING_LIFE_TO_ATTACK =
    Topic.wrap(uint256(keccak256("% of missing life to {element} attack")));
  Topic constant LEVEL = Topic.wrap(uint256(keccak256("level")));
}

using { toEntity, toStatmodEntity } for Topic global;

function toEntity(Topic topic) pure returns (uint256) {
  return Topic.unwrap(topic);
}

function toStatmodEntity(Topic topic, Op op, Element element) pure returns (uint256) {
  return getStatmodProtoEntity(StatmodPrototype({ topicEntity: topic.toEntity(), op: op, element: element }));
}
