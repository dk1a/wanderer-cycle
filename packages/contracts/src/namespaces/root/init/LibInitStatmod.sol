// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { commonSystem } from "../../common/codegen/systems/CommonSystemLib.sol";

import { PStat, PStat_length, StatmodOp, EleStat } from "../../../CustomTypes.sol";
import { StatmodTopics, StatmodTopic } from "../../statmod/StatmodTopic.sol";
import { statmodName } from "../../statmod/statmodName.sol";
import { LibSOFClass } from "../../common/LibSOFClass.sol";
import { StatmodBase, StatmodBaseData, StatmodIdxList, StatmodIdxMap, StatmodValue } from "../../statmod/codegen/index.sol";

library LibInitStatmod {
  function init(address deployer) internal {
    // primary stats
    for (uint256 i; i < StatmodTopics.PSTAT().length; i++) {
      _add(deployer, StatmodTopics.PSTAT()[i], StatmodOp.MUL);
      _add(deployer, StatmodTopics.PSTAT()[i], StatmodOp.ADD);
    }

    // secondary stats
    _add(deployer, StatmodTopics.FORTUNE, StatmodOp.MUL);
    _add(deployer, StatmodTopics.FORTUNE, StatmodOp.ADD);

    _add(deployer, StatmodTopics.CONNECTION, StatmodOp.MUL);
    _add(deployer, StatmodTopics.CONNECTION, StatmodOp.ADD);

    // currents
    _add(deployer, StatmodTopics.LIFE, StatmodOp.MUL);
    _add(deployer, StatmodTopics.LIFE, StatmodOp.ADD);
    _add(deployer, StatmodTopics.LIFE, StatmodOp.BADD);

    _add(deployer, StatmodTopics.MANA, StatmodOp.MUL);
    _add(deployer, StatmodTopics.MANA, StatmodOp.ADD);
    _add(deployer, StatmodTopics.MANA, StatmodOp.BADD);

    // currents gained per turn
    _add(deployer, StatmodTopics.LIFE_GAINED_PER_TURN, StatmodOp.ADD);
    _add(deployer, StatmodTopics.MANA_GAINED_PER_TURN, StatmodOp.ADD);

    // attack
    _add(deployer, StatmodTopics.ATTACK, StatmodOp.BADD, EleStat.PHYSICAL);

    _add(deployer, StatmodTopics.ATTACK, StatmodOp.MUL, EleStat.PHYSICAL);
    _add(deployer, StatmodTopics.ATTACK, StatmodOp.MUL, EleStat.FIRE);
    _add(deployer, StatmodTopics.ATTACK, StatmodOp.MUL, EleStat.COLD);
    _add(deployer, StatmodTopics.ATTACK, StatmodOp.MUL, EleStat.POISON);

    _add(deployer, StatmodTopics.ATTACK, StatmodOp.ADD, EleStat.PHYSICAL);
    _add(deployer, StatmodTopics.ATTACK, StatmodOp.ADD, EleStat.FIRE);
    _add(deployer, StatmodTopics.ATTACK, StatmodOp.ADD, EleStat.COLD);
    _add(deployer, StatmodTopics.ATTACK, StatmodOp.ADD, EleStat.POISON);

    // attack special
    _add(deployer, StatmodTopics.PERCENT_OF_MISSING_LIFE_TO_ATTACK, StatmodOp.ADD, EleStat.PHYSICAL);

    // spell
    _add(deployer, StatmodTopics.SPELL, StatmodOp.MUL);

    _add(deployer, StatmodTopics.SPELL, StatmodOp.ADD, EleStat.PHYSICAL);
    _add(deployer, StatmodTopics.SPELL, StatmodOp.ADD, EleStat.FIRE);
    _add(deployer, StatmodTopics.SPELL, StatmodOp.ADD, EleStat.COLD);

    // resistance
    _add(deployer, StatmodTopics.RESISTANCE, StatmodOp.ADD, EleStat.PHYSICAL);
    _add(deployer, StatmodTopics.RESISTANCE, StatmodOp.ADD, EleStat.FIRE);
    _add(deployer, StatmodTopics.RESISTANCE, StatmodOp.ADD, EleStat.COLD);
    _add(deployer, StatmodTopics.RESISTANCE, StatmodOp.ADD, EleStat.POISON);

    // damage taken per round
    _add(deployer, StatmodTopics.DAMAGE_TAKEN_PER_ROUND, StatmodOp.ADD, EleStat.PHYSICAL);
    _add(deployer, StatmodTopics.DAMAGE_TAKEN_PER_ROUND, StatmodOp.ADD, EleStat.FIRE);
    _add(deployer, StatmodTopics.DAMAGE_TAKEN_PER_ROUND, StatmodOp.ADD, EleStat.COLD);
    _add(deployer, StatmodTopics.DAMAGE_TAKEN_PER_ROUND, StatmodOp.ADD, EleStat.POISON);

    // debuffs
    _add(deployer, StatmodTopics.DAMAGE_TAKEN, StatmodOp.MUL);
    _add(deployer, StatmodTopics.REDUCED_DAMAGE_DONE, StatmodOp.ADD);
    _add(deployer, StatmodTopics.ROUNDS_STUNNED, StatmodOp.ADD);

    // level
    _add(deployer, StatmodTopics.LEVEL, StatmodOp.BADD);
  }

  function _add(address deployer, StatmodTopic topic, StatmodOp statmodOp) internal {
    _add(deployer, topic, statmodOp, EleStat.NONE);
  }

  function _add(address deployer, StatmodTopic topic, StatmodOp statmodOp, EleStat eleStat) internal {
    _add(deployer, StatmodBaseData({ statmodTopic: topic, statmodOp: statmodOp, eleStat: eleStat }));
  }

  function _add(address deployer, StatmodBaseData memory statmodBase) internal {
    bytes32 statmodEntity = LibSOFClass.instantiate("statmod", deployer);
    StatmodBase.set(statmodEntity, statmodBase);

    string memory name = statmodName(statmodBase);
    commonSystem.setName(statmodEntity, name);
  }
}
