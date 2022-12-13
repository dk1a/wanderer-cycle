// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import {
  SkillType,
  TargetType,
  SkillPrototype,
  SkillPrototypeComponent,
  ID as SkillPrototypeComponentID
} from "./SkillPrototypeComponent.sol";
import {
  SkillPrototypeExt,
  SkillPrototypeExtComponent,
  ID as SkillPrototypeExtComponentID
} from "./SkillPrototypeExtComponent.sol";
import { LibEffectPrototype } from "../effect/LibEffectPrototype.sol";
import { EffectPrototype, EffectRemovability, EffectStatmod } from "../effect/EffectPrototypeComponent.sol";

uint256 constant ID = uint256(keccak256("system.SkillPrototypeInit"));

contract SkillPrototypeInitSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  struct Comps {
    SkillPrototypeComponent protoComp;
    SkillPrototypeExtComponent protoExtComp;
  }

  function execute(
    SkillPrototype memory prototype,
    SkillPrototypeExt memory prototypeExt,
    EffectStatmod[] memory effectStatmods
  ) public {
    execute(abi.encode(prototype, prototypeExt, effectStatmods));
  }

  function execute(bytes memory arguments) public override onlyOwner returns (bytes memory) {
    (
      SkillPrototype memory prototype,
      SkillPrototypeExt memory prototypeExt,
      EffectStatmod[] memory effectStatmods
    ) = abi.decode(arguments, (SkillPrototype, SkillPrototypeExt, EffectStatmod[]));

    SkillPrototypeComponent protoComp
      = SkillPrototypeComponent(getAddressById(components, SkillPrototypeComponentID));
    SkillPrototypeExtComponent protoExtComp
      = SkillPrototypeExtComponent(getAddressById(components, SkillPrototypeExtComponentID));

    uint256 entity = uint256(keccak256(bytes(prototypeExt.name)));

    protoComp.set(entity, prototype);
    protoExtComp.set(entity, prototypeExt);

    // Given statmods, a skill will have an on-use effect prototype
    if (effectStatmods.length > 0) {
      EffectPrototype memory effectProto = EffectPrototype({
        removability: _getRemovability(prototype),
        statmods: effectStatmods
      });
      LibEffectPrototype.verifiedSet(components, entity, effectProto);
    }

    return '';
  }

  function _getRemovability(
    SkillPrototype memory skillProto
  ) private pure returns (EffectRemovability) {
    if (skillProto.skillType == SkillType.PASSIVE) {
      return EffectRemovability.PERSISTENT;
    } else if (skillProto.effectTarget == TargetType.ENEMY) {
      return EffectRemovability.DEBUFF;
    } else {
      return EffectRemovability.BUFF;
    }
  }
}