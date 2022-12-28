// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "@latticexyz/solecs/src/LibTypes.sol";
import { BareComponent } from "@latticexyz/solecs/src/BareComponent.sol";

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
