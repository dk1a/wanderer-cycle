// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { ScopedDuration, EL_L, getSkillProtoEntity, SkillPrototype, SkillPrototypeComponent, ID as SkillPrototypeComponentID } from "../skill/SkillPrototypeComponent.sol";
import { SkillDescriptionComponent, ID as SkillDescriptionComponentID } from "../skill/SkillDescriptionComponent.sol";
import { LibEffectPrototype } from "../effect/LibEffectPrototype.sol";
import { EffectPrototype } from "../effect/EffectPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

library LibBaseInitSkill {
  struct Comps {
    IUint256Component components;
    SkillPrototypeComponent protoComp;
    SkillDescriptionComponent descComp;
    NameComponent nameComp;
  }

  function getComps(IUint256Component components) internal view returns (Comps memory result) {
    result.components = components;
    result.protoComp = SkillPrototypeComponent(getAddressById(components, SkillPrototypeComponentID));
    result.descComp = SkillDescriptionComponent(getAddressById(components, SkillDescriptionComponentID));
    result.nameComp = NameComponent(getAddressById(components, NameComponentID));
  }

  function add(
    Comps memory comps,
    string memory name,
    string memory description,
    SkillPrototype memory prototype,
    EffectPrototype memory effectProto
  ) internal {
    uint256 entity = getSkillProtoEntity(name);

    comps.protoComp.set(entity, prototype);
    comps.descComp.set(entity, description);
    comps.nameComp.set(entity, name);

    // Given statmods, a Skill will have an on-use effect prototype
    if (effectProto.statmodProtoEntities.length > 0) {
      LibEffectPrototype.verifiedSet(comps.components, entity, effectProto);
    }
  }

  function _duration(string memory timeScope, uint256 timeValue) internal pure returns (ScopedDuration memory) {
    return ScopedDuration({ timeScopeId: uint256(keccak256(bytes(timeScope))), timeValue: timeValue });
  }

  function _noDuration() internal pure returns (ScopedDuration memory) {
    return _duration("", 0);
  }

  function _emptyElemental() internal pure returns (uint32[EL_L] memory) {
    return [uint32(0), 0, 0, 0, 0];
  }
}
