// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { SkillPrototypeInitSystem, ID as SkillPrototypeInitSystemID } from "../skill/SkillPrototypeInitSystem.sol";
import {
  SkillType,
  TargetType,
  TimeStruct,
  EffectStatmod,
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

library LibInitSkill {
  function initialize(IWorld world) internal {
    SkillPrototypeInitSystem system = SkillPrototypeInitSystem(getAddressById(world.systems(), SkillPrototypeInitSystemID));

    // 1
    system.execute(
      SkillPrototype({
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: false,
        cost: 1,
        duration: _timeStruct('round', 1),
        cooldown: _timeStruct('round', 1),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental(),
        statmods: _statmods(
          '#% increased attack', 16,
          '+# physical to attack', 2
        )
      }),
      SkillPrototypeExt({
        name: 'Cleave',
        description: 'Attack with increased damage'
      })
    );

    // 2 
    system.execute(
      SkillPrototype({
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 1,
        duration: _timeStruct('round_persistent', 1),
        cooldown: _timeStruct('turn', 3),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental(),
        statmods: _statmods(
          '#% increased attack', 64
        )
      }),
      SkillPrototypeExt({
        name: 'Charge',
        description: 'Greatly increase attack damage for the next combat round'
      })
    );

    // 3
    system.execute(
      SkillPrototype({
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noTime(),
        cooldown: _noTime(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental(),
        statmods: _statmods(
          '+# physical resistance', 8
        )
      }),
      SkillPrototypeExt({
        name: 'Parry',
        description: 'Increase physical resistance'
      })
    );

    // 4
    system.execute(
      SkillPrototype({
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 1,
        duration: _timeStruct('turn', 2),
        cooldown: _timeStruct('turn', 8),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental(),
        statmods: _statmods(
          '#% increased attack', 32,
          '+# life gained each turn', 2
        )
      }),
      SkillPrototypeExt({
        name: 'Onslaught',
        description: 'Increase attack damage and recover some life per round'
      })
    );

    // 5
    system.execute(
      SkillPrototype({
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noTime(),
        cooldown: _noTime(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental(),
        statmods: _statmods(
          '#% increased life', 8
        )
      }),
      SkillPrototypeExt({
        name: 'Toughness',
        description: 'Increase life'
      })
    );

    // 6
    system.execute(
      SkillPrototype({
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: true,
        cost: 4,
        duration: _noTime(),
        cooldown: _timeStruct("round", 4),
        effectTarget: TargetType.SELF,
        spellDamage: [uint32(0), 4, 0, 0, 0],
        statmods: _statmods()
      }),
      SkillPrototypeExt({
        name: 'Thunder Clap',
        description: 'Attack and deal 8 physical spell damage'
      })
    );

    // 7
    system.execute(
      SkillPrototype({
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noTime(),
        cooldown: _noTime(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental(),
        statmods: _statmods(
          '#% increased attack', 8
        )
      }),
      SkillPrototypeExt({
        name: 'Precise Strikes',
        description: 'Increase attack damage'
      })
    );

    // 8
    system.execute(
      SkillPrototype({
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noTime(),
        // TODO this should have a day(?) cooldown somehow, maybe not here though
        cooldown: _noTime(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental(),
        statmods: _statmods()
      }),
      SkillPrototypeExt({
        name: 'Blood Rage',
        description: 'Gain an extra turn after a kill, once per day'
      })
    );

    // 9
    system.execute(
      SkillPrototype({
        skillType: SkillType.NONCOMBAT,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _timeStruct('turn', 1),
        cooldown: _timeStruct('turn', 16),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental(),
        statmods: _statmods(
          '+# physical resistance', 8,
          '+#% of missing life to physical attack', 400
        )
      }),
      SkillPrototypeExt({
        name: 'Retaliation',
        description: 'Increases physical resistance\nIncreases physical attack damage proportional to missing life'
      })
    );

    // 10
    system.execute(
      SkillPrototype({
        skillType: SkillType.COMBAT,
        withAttack: true,
        withSpell: false,
        cost: 1,
        duration: _timeStruct('round', 4),
        cooldown: _timeStruct('turn', 8),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental(),
        statmods: _statmods(
          '#% increased life', 32,
          // TODO should this even be a modifier?
          'recover #% of base life', 32
        )
      }),
      SkillPrototypeExt({
        name: 'Last Stand',
        description: 'Gain temporary life for 4 rounds'
      })
    );

    // 11
    system.execute(
      SkillPrototype({
        skillType: SkillType.PASSIVE,
        withAttack: false,
        withSpell: false,
        cost: 0,
        duration: _noTime(),
        cooldown: _noTime(),
        effectTarget: TargetType.SELF,
        spellDamage: _emptyElemental(),
        statmods: _statmods(
          '+# physical to base attack', 1
        )
      }),
      SkillPrototypeExt({
        name: 'Weapon Mastery',
        // TODO this dual-wielding thing
        description: 'Allows dual wielding one-handed weapons\nIncreases base attack'
      })
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