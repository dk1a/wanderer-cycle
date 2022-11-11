// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";
import { EL_L } from "../statmod/StatmodPrototypeComponent.sol";
import { TimeStruct } from "../turn-based-time/TBTime.sol";
import { EffectStatmod } from "../effect/AppliedEffectComponent.sol";

uint256 constant ID = uint256(keccak256("component.SkillPrototype"));

enum SkillType {
  COMBAT,
  NONCOMBAT,
  PASSIVE
}
enum TargetType {
  SELF,
  ENEMY,
  ALLY,
  SELF_OR_ALLY
}
struct SkillPrototype {
  // level required to learn it
  uint8 requiredLevel;
  // when/how can it be used
  SkillType skillType;
  // by default a skill only applies effects
  // flag to also trigger an attack afterwards (base attack damage is not based on the skill)
  bool withAttack;
  // flag to also trigger a spell afterwards (base spell damage is the skill's `spellDamage`)
  bool withSpell;
  // mana cost to be subtracted on use
  uint32 cost;
  // duration of effect (important only if modifiers are present)
  TimeStruct duration;
  // cooldown of skill
  TimeStruct cooldown;
  // who can it be used on (also affects resulting effect's removability)
  TargetType effectTarget;
  // used only if withSpell == true
  uint32[EL_L] spellDamage;
  // skill's effect is made of modifiers
  // (one modifier id may be used in different skills - effects aggregate modifier values by topic)
  EffectStatmod[] statmods;
}

contract SkillPrototypeComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](9);
    values = new LibTypes.SchemaValue[](9);

    // TODO this
    /*keys[0] = "topic";
    values[0] = LibTypes.SchemaValue.BYTES4;*/
  }

  function set(uint256 entity, SkillPrototype memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (SkillPrototype memory) {
    return abi.decode(getRawValue(entity), (SkillPrototype));
  }
}

