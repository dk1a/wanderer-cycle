// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { EleStat_length } from "../../../CustomTypes.sol";
import { GenericDurationData } from "../../duration/Duration.sol";
import { LibEffectTemplate, EffectTemplateData } from "../../effect/LibEffectTemplate.sol";
import { SkillTemplate, SkillTemplateData, SkillTemplateCooldown, SkillTemplateDuration, SkillDescription, SkillNameToEntity, SkillSpellDamage, Name } from "../codegen/index.sol";
import { LibSkill } from "../skill/LibSkill.sol";

library LibBaseInitSkill {
  error LibBaseInitSkill_DuplicateName(string name);

  function add(
    string memory name,
    string memory description,
    SkillTemplateData memory template,
    GenericDurationData memory cooldown,
    GenericDurationData memory duration,
    EffectTemplateData memory effectTemplate,
    uint32[EleStat_length] memory spellDamage
  ) internal {
    bytes32 nameHash = keccak256(bytes(name));
    if (SkillNameToEntity.get(nameHash) != bytes32(0)) {
      revert LibBaseInitSkill_DuplicateName(name);
    }

    bytes32 entity = getUniqueEntity();

    SkillTemplate.set(entity, template);
    LibSkill.setSkillTemplateCooldown(entity, cooldown);
    LibSkill.setSkillTemplateDuration(entity, duration);
    SkillSpellDamage.set(entity, spellDamage);
    SkillDescription.set(entity, description);
    SkillNameToEntity.set(keccak256(bytes(name)), entity);
    Name.set(entity, name);

    // Given statmods, a skill will have an on-use effect template
    if (effectTemplate.entities.length > 0) {
      LibEffectTemplate.verifiedSet(entity, effectTemplate);
    }
  }

  function _noDuration() internal pure returns (GenericDurationData memory) {
    return GenericDurationData({ timeId: "", timeValue: 0 });
  }

  function _emptyElemental() internal pure returns (uint32[EleStat_length] memory) {
    return [uint32(0), 0, 0, 0, 0];
  }
}
