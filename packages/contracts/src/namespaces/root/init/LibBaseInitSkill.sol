// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { effectTemplateSystem, EffectTemplateData } from "../../effect/codegen/systems/EffectTemplateSystemLib.sol";

import { EleStat_length } from "../../../CustomTypes.sol";
import { GenericDurationData } from "../../duration/Duration.sol";
import { LibSkill } from "../../skill/LibSkill.sol";

import { SkillTemplate, SkillTemplateData } from "../../skill/codegen/tables/SkillTemplate.sol";
import { SkillTemplateCooldown } from "../../skill/codegen/tables/SkillTemplateCooldown.sol";
import { SkillTemplateDuration } from "../../skill/codegen/tables/SkillTemplateDuration.sol";
import { SkillDescription } from "../../skill/codegen/tables/SkillDescription.sol";
import { SkillSpellDamage } from "../../skill/codegen/tables/SkillSpellDamage.sol";
import { SkillName } from "../../skill/codegen/tables/SkillName.sol";

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
    bytes32 entity = getUniqueEntity();

    SkillTemplate.set(entity, template);
    LibSkill.setSkillTemplateCooldown(entity, cooldown);
    LibSkill.setSkillTemplateDuration(entity, duration);
    SkillSpellDamage.set(entity, spellDamage);
    SkillDescription.set(entity, description);
    SkillName.set(entity, name);

    // Given statmods, a skill will have an on-use effect template
    if (effectTemplate.statmodEntities.length > 0) {
      effectTemplateSystem.setEffectTemplate(entity, effectTemplate);
    }
  }

  function _noDuration() internal pure returns (GenericDurationData memory) {
    return GenericDurationData({ timeId: "", timeValue: 0 });
  }

  function _emptyElemental() internal pure returns (uint32[EleStat_length] memory) {
    return [uint32(0), 0, 0, 0, 0];
  }
}
