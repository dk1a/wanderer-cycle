// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SmartObjectFramework } from "../evefrontier/SmartObjectFramework.sol";

import { StatmodBase } from "../statmod/codegen/index.sol";
import { EffectTemplate, EffectTemplateData } from "./codegen/tables/EffectTemplate.sol";
import { AffixPrototype } from "../affix/codegen/tables/AffixPrototype.sol";
import { Affix } from "../affix/codegen/tables/Affix.sol";
import { StatmodTopic } from "../statmod/StatmodTopic.sol";

contract EffectTemplateSystem is SmartObjectFramework {
  error EffectTemplateSystem_LengthMismatch();
  error EffectTemplateSystem_InvalidStatmod(bytes32 statmodEntity);

  /**
   * @dev Check data validity before setting effect template
   */
  function setEffectTemplate(bytes32 applicationEntity, EffectTemplateData memory effectTemplateData) public context {
    _requireEntityLeaf(applicationEntity);

    // Verify lengths
    if (effectTemplateData.statmodEntities.length != effectTemplateData.values.length) {
      revert EffectTemplateSystem_LengthMismatch();
    }
    // Verify statmods existence
    for (uint256 i; i < effectTemplateData.statmodEntities.length; i++) {
      bytes32 statmodEntity = effectTemplateData.statmodEntities[i];
      if (StatmodTopic.unwrap(StatmodBase.getStatmodTopic(statmodEntity)) == bytes32(0)) {
        revert EffectTemplateSystem_InvalidStatmod(statmodEntity);
      }
    }
    // Set
    EffectTemplate.set(applicationEntity, effectTemplateData);
  }

  function setEffectTemplateFromAffixes(bytes32 applicationEntity, bytes32[] memory affixEntities) public {
    bytes32[] memory statmodEntities = new bytes32[](affixEntities.length);
    uint32[] memory values = new uint32[](affixEntities.length);

    for (uint256 i; i < affixEntities.length; i++) {
      bytes32 affixProtoEntity = Affix.getAffixPrototypeEntity(affixEntities[i]);
      statmodEntities[i] = AffixPrototype.getStatmodEntity(affixProtoEntity);
      values[i] = Affix.getValue(affixEntities[i]);
    }

    EffectTemplateData memory effectTemplateData = EffectTemplateData({
      statmodEntities: statmodEntities,
      values: values
    });

    setEffectTemplate(applicationEntity, effectTemplateData);
  }
}
