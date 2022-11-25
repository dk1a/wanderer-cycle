// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { PS_L } from "./LibExperience.sol";

library Topics {
  // TODO is this ok?
  // pstat topics are an array since it's often useful to iterate them
  function PSTAT() internal pure returns (bytes4[PS_L] memory) {
    return [
      bytes4(keccak256('strength')),
      bytes4(keccak256('arcana')),
      bytes4(keccak256('dexterity'))
    ];
  }

  bytes4 constant LIFE = bytes4(keccak256('life'));
  bytes4 constant MANA = bytes4(keccak256('mana'));
  bytes4 constant FORTUNE = bytes4(keccak256('fortune'));
  bytes4 constant CONNECTION = bytes4(keccak256('connection'));
  bytes4 constant LIFE_REGEN = bytes4(keccak256('lifeRegen'));
  bytes4 constant MANA_REGEN = bytes4(keccak256('manaRegen'));

  bytes4 constant ATTACK = bytes4(keccak256('attack'));
  bytes4 constant SPELL = bytes4(keccak256('spell'));
  bytes4 constant RESISTANCE = bytes4(keccak256('resistance'));

  bytes4 constant ROUND_DAMAGE = bytes4(keccak256('round damage'));

  bytes4 constant DAMAGE_TAKEN_ADD = bytes4(keccak256('damage taken add'));
  bytes4 constant DAMAGE_DONE_SUB = bytes4(keccak256('damage done sub'));
  bytes4 constant STUN = bytes4(keccak256('stun'));

  bytes4 constant PORTION_OF_MISSING_LIFE_ATTACK = bytes4(keccak256('portion of missing life attack'));
  bytes4 constant LEVEL = bytes4(keccak256('level'));
}