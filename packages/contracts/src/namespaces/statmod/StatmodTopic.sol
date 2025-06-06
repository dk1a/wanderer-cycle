// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { PStat, PStat_length, StatmodOp, EleStat } from "../../CustomTypes.sol";
import { StatmodBaseData } from "./codegen/tables/StatmodBase.sol";
import { UniqueIdx_StatmodBase_StatmodTopicStatmodOpEleStat } from "./codegen/idxs/UniqueIdx_StatmodBase_StatmodTopicStatmodOpEleStat.sol";

type StatmodTopic is bytes32;

library StatmodTopics {
  StatmodTopic constant STRENGTH = StatmodTopic.wrap("strength");
  StatmodTopic constant ARCANA = StatmodTopic.wrap("arcana");
  StatmodTopic constant DEXTERITY = StatmodTopic.wrap("dexterity");

  // pstat topics also come as an array since it's often useful to iterate them
  function PSTAT() internal pure returns (StatmodTopic[PStat_length] memory r) {
    r[uint256(PStat.STRENGTH)] = STRENGTH;
    r[uint256(PStat.ARCANA)] = ARCANA;
    r[uint256(PStat.DEXTERITY)] = DEXTERITY;
  }

  StatmodTopic constant LIFE = StatmodTopic.wrap("life");
  StatmodTopic constant MANA = StatmodTopic.wrap("mana");
  StatmodTopic constant FORTUNE = StatmodTopic.wrap("fortune");
  StatmodTopic constant CONNECTION = StatmodTopic.wrap("connection");
  StatmodTopic constant LIFE_GAINED_PER_TURN = StatmodTopic.wrap("life gained per turn");
  StatmodTopic constant MANA_GAINED_PER_TURN = StatmodTopic.wrap("mana gained per turn");

  StatmodTopic constant ATTACK = StatmodTopic.wrap("attack");
  StatmodTopic constant SPELL = StatmodTopic.wrap("spell");
  StatmodTopic constant RESISTANCE = StatmodTopic.wrap("resistance");

  StatmodTopic constant DAMAGE_TAKEN_PER_ROUND = StatmodTopic.wrap("damage taken per round");

  StatmodTopic constant DAMAGE_TAKEN = StatmodTopic.wrap("damage taken");
  StatmodTopic constant REDUCED_DAMAGE_DONE = StatmodTopic.wrap("reduced damage done");
  StatmodTopic constant ROUNDS_STUNNED = StatmodTopic.wrap("rounds stunned");

  StatmodTopic constant PERCENT_OF_MISSING_LIFE_TO_ATTACK = StatmodTopic.wrap("% of missing life to {el} attack");
  StatmodTopic constant LEVEL = StatmodTopic.wrap("level");
}

using StatmodTopicInstance for StatmodTopic global;
using { eq as ==, ne as != } for StatmodTopic global;

library StatmodTopicInstance {
  error StatmodTopicInstance_StatmodNotFound(StatmodTopic statmodTopic, StatmodOp statmodOp, EleStat eleStat);

  function toStatmodEntity(
    StatmodTopic statmodTopic,
    StatmodOp statmodOp,
    EleStat eleStat
  ) internal view returns (bytes32 statmodEntity) {
    statmodEntity = UniqueIdx_StatmodBase_StatmodTopicStatmodOpEleStat.get({
      statmodTopic: statmodTopic,
      statmodOp: statmodOp,
      eleStat: eleStat
    });
    if (statmodEntity == bytes32(0)) {
      revert StatmodTopicInstance_StatmodNotFound(statmodTopic, statmodOp, eleStat);
    }
  }
}

function eq(StatmodTopic a, StatmodTopic b) pure returns (bool) {
  return StatmodTopic.unwrap(a) == StatmodTopic.unwrap(b);
}

function ne(StatmodTopic a, StatmodTopic b) pure returns (bool) {
  return StatmodTopic.unwrap(a) != StatmodTopic.unwrap(b);
}
