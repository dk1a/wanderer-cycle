// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { SkillPrototypeInitSystem, ID as SkillPrototypeInitSystemID } from "../skill/SkillPrototypeInitSystem.sol";
import {
  SkillType,
  TargetType,
  TimeStruct,
  EL_L,
  SkillPrototype,
  SkillPrototypeComponent,
  ID as SkillPrototypeComponentID
} from "../skill/SkillPrototypeComponent.sol";
import {
  SkillPrototypeExt,
  SkillPrototypeExtComponent,
  ID as SkillPrototypeExtComponentID
} from "../skill/SkillPrototypeExtComponent.sol";
import { EffectStatmod } from "../effect/EffectPrototypeComponent.sol";

library LibInitSkill {
  function initialize(IWorld world) internal {
    SkillPrototypeInitSystem system = SkillPrototypeInitSystem(getAddressById(world.systems(), SkillPrototypeInitSystemID));

    // 1
    system.execute(
      SkillPrototype({
        requiredLevel: 1,
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: false,
        cost: 1,
        duration: _timeStruct('round', 1),
        cooldown: _timeStruct('round', 1),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      SkillPrototypeExt({
        name: 'Cleave',
        description: 'Attack with increased damage'
      }),
      _statmods(
        '#% increased attack', 16,
        '+# physical to attack', 2
      )
    );

    // 2 
    system.execute(
      SkillPrototype({
        requiredLevel: 2,
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 1,
        duration: _timeStruct('round_persistent', 1),
        cooldown: _timeStruct('turn', 3),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      SkillPrototypeExt({
        name: 'Charge',
        description: 'Greatly increase attack damage for the next combat round'
      }),
      _statmods(
        '#% increased attack', 64
      )
    );

    // 3
    system.execute(
      SkillPrototype({
        requiredLevel: 3,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noTime(),
        cooldown: _noTime(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      SkillPrototypeExt({
        name: 'Parry',
        description: 'Increase physical resistance'
      }),
      _statmods(
        '+# physical resistance', 8
      )
    );

    // 4
    system.execute(
      SkillPrototype({
        requiredLevel: 4,
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 1,
        duration: _timeStruct('turn', 2),
        cooldown: _timeStruct('turn', 8),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      SkillPrototypeExt({
        name: 'Onslaught',
        description: 'Increase attack damage and recover some life per round'
      }),
      _statmods(
        '#% increased attack', 32,
        '+# life gained each turn', 2
      )
    );

    // 5
    system.execute(
      SkillPrototype({
        requiredLevel: 5,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noTime(),
        cooldown: _noTime(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      SkillPrototypeExt({
        name: 'Toughness',
        description: 'Increase life'
      }),
      _statmods(
        '#% increased life', 8
      )
    );

    // 6
    system.execute(
      SkillPrototype({
        requiredLevel: 6,
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: true,
        cost: 4,
        duration: _noTime(),
        cooldown: _timeStruct("round", 4),
        effectTarget: TargetType.SELF,
        spellDamage: [uint32(0), 8, 0, 0, 0]
      }),
      SkillPrototypeExt({
        name: 'Thunder Clap',
        description: 'Attack and deal physical spell damage'
      }),
      _statmods()
    );

    // 7
    system.execute(
      SkillPrototype({
        requiredLevel: 7,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noTime(),
        cooldown: _noTime(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      SkillPrototypeExt({
        name: 'Precise Strikes',
        description: 'Increase attack damage'
      }),
      _statmods(
        '#% increased attack', 8
      )
    );

    // 8
    system.execute(
      SkillPrototype({
        requiredLevel: 8,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noTime(),
        // TODO this should have a day(?) cooldown somehow, maybe not here though
        cooldown: _noTime(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      SkillPrototypeExt({
        name: 'Blood Rage',
        description: 'Gain an extra turn after a kill, once per day'
      }),
      _statmods()
    );

    // 9
    system.execute(
      SkillPrototype({
        requiredLevel: 9,
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _timeStruct('turn', 1),
        cooldown: _timeStruct('turn', 16),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      SkillPrototypeExt({
        name: 'Retaliation',
        description: 'Increases physical resistance\nIncreases physical attack damage proportional to missing life'
      }),
      _statmods(
        '+# physical resistance', 8,
        '+#% of missing life to physical attack', 400
      )
    );

    // 10
    system.execute(
      SkillPrototype({
        requiredLevel: 10,
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: false,
        cost: 1,
        duration: _timeStruct('round', 4),
        cooldown: _timeStruct('turn', 8),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      SkillPrototypeExt({
        name: 'Last Stand',
        description: 'Gain temporary life for 4 rounds'
      }),
      _statmods(
        '#% increased life', 32,
        // TODO should this even be a modifier?
        'recover #% of base life', 32
      )
    );

    // 11
    system.execute(
      SkillPrototype({
        requiredLevel: 11,
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noTime(),
        cooldown: _noTime(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental()
      }),
      SkillPrototypeExt({
        name: 'Weapon Mastery',
        // TODO this dual-wielding thing
        description: 'Allows dual wielding one-handed weapons\nIncreases base attack'
      }),
      _statmods(
        '+# physical to base attack', 1
      )
    );
  }


  // ================ HELPERS ================

  function _timeStruct(string memory timeTopic, uint256 timeValue) private pure returns (TimeStruct memory) {
    return TimeStruct({
      timeTopic: bytes4(keccak256(bytes(timeTopic))),
      timeValue: timeValue
    });
  }

  function _noTime() private pure returns (TimeStruct memory) {
    return _timeStruct('', 0);
  }

  function _emptyElemental() private pure returns (uint32[EL_L] memory) {
    return [uint32(0), 0, 0, 0, 0];
  }

  function _statmods() private pure returns (EffectStatmod[] memory) {}

  function _statmods(
    bytes memory name0, uint256 value0
  ) private pure returns (EffectStatmod[] memory result) {
    result = new EffectStatmod[](1);

    result[0].statmodProtoEntity = uint256(keccak256(name0));
    result[0].value = value0;
  }

  function _statmods(
    bytes memory name0, uint256 value0,
    bytes memory name1, uint256 value1
  ) private pure returns (EffectStatmod[] memory result) {
    result = new EffectStatmod[](2);

    result[0].statmodProtoEntity = uint256(keccak256(name0));
    result[0].value = value0;

    result[1].statmodProtoEntity = uint256(keccak256(name1));
    result[1].value = value1;
  }

  function _statmods(
    bytes memory name0, uint256 value0,
    bytes memory name1, uint256 value1,
    bytes memory name2, uint256 value2
  ) private pure returns (EffectStatmod[] memory result) {
    result = new EffectStatmod[](2);

    result[0].statmodProtoEntity = uint256(keccak256(name0));
    result[0].value = value0;

    result[1].statmodProtoEntity = uint256(keccak256(name1));
    result[1].value = value1;

    result[2].statmodProtoEntity = uint256(keccak256(name2));
    result[2].value = value2;
  }
}