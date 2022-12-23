// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import {
  SkillType,
  TargetType,
  ScopedDuration,
  EL_L,
  getSkillProtoEntity,
  SkillPrototype,
  SkillPrototypeComponent,
  ID as SkillPrototypeComponentID
} from "../skill/SkillPrototypeComponent.sol";
import { SkillDescriptionComponent, ID as SkillDescriptionComponentID } from "../skill/SkillDescriptionComponent.sol";
import { LibEffectPrototype } from "../effect/LibEffectPrototype.sol";
import { EffectPrototype, EffectRemovability, EffectStatmod } from "../effect/EffectPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

abstract contract BaseInitSkillSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function _duration(string memory timeScope, uint256 timeValue) internal pure returns (ScopedDuration memory) {
    return ScopedDuration({
      timeScopeId: uint256(keccak256(bytes(timeScope))),
      timeValue: timeValue
    });
  }

  function _noDuration() internal pure returns (ScopedDuration memory) {
    return _duration('', 0);
  }

  function _emptyElemental() internal pure returns (uint32[EL_L] memory) {
    return [uint32(0), 0, 0, 0, 0];
  }

  function add(
    string memory name,
    string memory description,
    SkillPrototype memory prototype,
    EffectStatmod[] memory effectStatmods
  ) internal {
    SkillPrototypeComponent protoComp = SkillPrototypeComponent(getAddressById(components, SkillPrototypeComponentID));
    SkillDescriptionComponent descComp = SkillDescriptionComponent(getAddressById(components, SkillDescriptionComponentID));
    NameComponent nameComp = NameComponent(getAddressById(components, NameComponentID));

    uint256 entity = getSkillProtoEntity(name);

    protoComp.set(entity, prototype);
    descComp.set(entity, description);
    nameComp.set(entity, name);

    // Given statmods, a skill will have an on-use effect prototype
    if (effectStatmods.length > 0) {
      EffectPrototype memory effectProto = EffectPrototype({
        removability: _getRemovability(prototype),
        statmods: effectStatmods
      });
      LibEffectPrototype.verifiedSet(components, entity, effectProto);
    }
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