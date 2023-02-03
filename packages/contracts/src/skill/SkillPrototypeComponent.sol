// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

import { EL_L } from "../statmod/StatmodPrototypeComponent.sol";
import { ScopedDuration } from "../duration/DurationSubsystem.sol";

uint256 constant ID = uint256(keccak256("component.SkillPrototype"));

/**
 * @dev Skill protoEntity = hashed(ID, name)
 */
function getSkillProtoEntity(string memory name) pure returns (uint256) {
  return uint256(keccak256(abi.encode(ID, name)));
}

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
  ScopedDuration duration;
  // cooldown of skill
  ScopedDuration cooldown;
  // who can it be used on (also affects resulting effect's removability)
  TargetType effectTarget;
  // used only if withSpell == true
  uint32[EL_L] spellDamage;
}

contract SkillPrototypeComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](5 + 2 + 2 + 1 + EL_L);
    values = new LibTypes.SchemaValue[](5 + 2 + 2 + 1 + EL_L);

    keys[0] = "requiredLevel";
    values[0] = LibTypes.SchemaValue.UINT8;

    keys[1] = "skillType";
    values[1] = LibTypes.SchemaValue.UINT8;

    keys[2] = "withAttack";
    values[2] = LibTypes.SchemaValue.BOOL;

    keys[3] = "withSpell";
    values[3] = LibTypes.SchemaValue.BOOL;

    keys[4] = "cost";
    values[4] = LibTypes.SchemaValue.UINT32;

    keys[5] = "duration_timeScopeId";
    values[5] = LibTypes.SchemaValue.UINT256;

    keys[6] = "duration_timeScopeId";
    values[6] = LibTypes.SchemaValue.UINT256;

    keys[7] = "cooldown_timeScopeId";
    values[7] = LibTypes.SchemaValue.UINT256;

    keys[8] = "cooldown_timeScopeId";
    values[8] = LibTypes.SchemaValue.UINT256;

    keys[9] = "effectTarget";
    values[9] = LibTypes.SchemaValue.UINT8;

    keys[10] = "spellDamage_all";
    values[10] = LibTypes.SchemaValue.UINT32;

    keys[11] = "spellDamage_physical";
    values[11] = LibTypes.SchemaValue.UINT32;

    keys[12] = "spellDamage_fire";
    values[12] = LibTypes.SchemaValue.UINT32;

    keys[13] = "spellDamage_cold";
    values[13] = LibTypes.SchemaValue.UINT32;

    keys[14] = "spellDamage_poison";
    values[14] = LibTypes.SchemaValue.UINT32;
  }

  function set(uint256 entity, SkillPrototype memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (SkillPrototype memory) {
    return abi.decode(getRawValue(entity), (SkillPrototype));
  }
}

