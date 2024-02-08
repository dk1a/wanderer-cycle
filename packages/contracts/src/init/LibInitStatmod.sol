// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { StatmodTopics, StatmodTopic, toStatmodEntity } from "../statmod/StatmodTopic.sol";
import { statmodName } from "../statmod/statmodName.sol";
import { Name, StatmodBase, StatmodBaseData, StatmodIdxList, StatmodIdxMap, StatmodValue } from "../codegen/index.sol";
import { PStat, PStat_length, StatmodOp, EleStat } from "../CustomTypes.sol";

library LibInitStatmod {
  function init() internal {
    // primary stats
    for (uint256 i; i < StatmodTopics.PSTAT().length; i++) {
      _add(StatmodTopics.PSTAT()[i], StatmodOp.MUL);
      _add(StatmodTopics.PSTAT()[i], StatmodOp.ADD);
    }

    // secondary stats
    _add(StatmodTopics.FORTUNE, StatmodOp.MUL);
    _add(StatmodTopics.FORTUNE, StatmodOp.ADD);

    _add(StatmodTopics.CONNECTION, StatmodOp.MUL);
    _add(StatmodTopics.CONNECTION, StatmodOp.ADD);

    // currents
    _add(StatmodTopics.LIFE, StatmodOp.MUL);
    _add(StatmodTopics.LIFE, StatmodOp.ADD);
    _add(StatmodTopics.LIFE, StatmodOp.BADD);

    _add(StatmodTopics.MANA, StatmodOp.MUL);
    _add(StatmodTopics.MANA, StatmodOp.ADD);
    _add(StatmodTopics.MANA, StatmodOp.BADD);

    // currents gained per turn
    _add(StatmodTopics.LIFE_GAINED_PER_TURN, StatmodOp.ADD);
    _add(StatmodTopics.MANA_GAINED_PER_TURN, StatmodOp.ADD);

    // attack
    _add(StatmodTopics.ATTACK, StatmodOp.BADD, EleStat.PHYSICAL);

    _add(StatmodTopics.ATTACK, StatmodOp.MUL, EleStat.PHYSICAL);
    _add(StatmodTopics.ATTACK, StatmodOp.MUL, EleStat.FIRE);
    _add(StatmodTopics.ATTACK, StatmodOp.MUL, EleStat.COLD);
    _add(StatmodTopics.ATTACK, StatmodOp.MUL, EleStat.POISON);

    _add(StatmodTopics.ATTACK, StatmodOp.ADD, EleStat.PHYSICAL);
    _add(StatmodTopics.ATTACK, StatmodOp.ADD, EleStat.FIRE);
    _add(StatmodTopics.ATTACK, StatmodOp.ADD, EleStat.COLD);
    _add(StatmodTopics.ATTACK, StatmodOp.ADD, EleStat.POISON);

    // attack special
    _add(StatmodTopics.PERCENT_OF_MISSING_LIFE_TO_ATTACK, StatmodOp.ADD, EleStat.PHYSICAL);

    // spell
    _add(StatmodTopics.SPELL, StatmodOp.MUL);

    _add(StatmodTopics.SPELL, StatmodOp.ADD, EleStat.PHYSICAL);
    _add(StatmodTopics.SPELL, StatmodOp.ADD, EleStat.FIRE);
    _add(StatmodTopics.SPELL, StatmodOp.ADD, EleStat.COLD);

    // resistance
    _add(StatmodTopics.RESISTANCE, StatmodOp.ADD, EleStat.PHYSICAL);
    _add(StatmodTopics.RESISTANCE, StatmodOp.ADD, EleStat.FIRE);
    _add(StatmodTopics.RESISTANCE, StatmodOp.ADD, EleStat.COLD);
    _add(StatmodTopics.RESISTANCE, StatmodOp.ADD, EleStat.POISON);

    // damage taken per round
    _add(StatmodTopics.DAMAGE_TAKEN_PER_ROUND, StatmodOp.ADD, EleStat.PHYSICAL);
    _add(StatmodTopics.DAMAGE_TAKEN_PER_ROUND, StatmodOp.ADD, EleStat.FIRE);
    _add(StatmodTopics.DAMAGE_TAKEN_PER_ROUND, StatmodOp.ADD, EleStat.COLD);
    _add(StatmodTopics.DAMAGE_TAKEN_PER_ROUND, StatmodOp.ADD, EleStat.POISON);

    // debuffs
    _add(StatmodTopics.DAMAGE_TAKEN, StatmodOp.MUL);
    _add(StatmodTopics.REDUCED_DAMAGE_DONE, StatmodOp.ADD);
    _add(StatmodTopics.ROUNDS_STUNNED, StatmodOp.ADD);

    // level
    _add(StatmodTopics.LEVEL, StatmodOp.BADD);
  }

  function _add(StatmodTopic topic, StatmodOp statmodOp) internal {
    _add(topic, statmodOp, EleStat.NONE);
  }

  function _add(StatmodTopic topic, StatmodOp statmodOp, EleStat eleStat) internal {
    _add(StatmodBaseData({ statmodTopic: topic, statmodOp: statmodOp, eleStat: eleStat }));
  }

  function _add(StatmodBaseData memory statmodBase) internal {
    bytes32 statmodEntity = statmodBase.statmodTopic.toStatmodEntity(statmodBase.statmodOp, statmodBase.eleStat);
    StatmodBase.set(statmodEntity, statmodBase);

    string memory name = statmodName(statmodBase);
    Name.set(statmodEntity, name);
  }
}
