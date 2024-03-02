// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { EffectTemplate, EffectTemplateData, StatmodBase } from "../../codegen/index.sol";
import { StatmodTopic } from "../statmod/StatmodTopic.sol";

// TODO this can probably be a hook
library LibEffectTemplate {
  error LibEffectTemplate_LengthMismatch();
  error LibEffectTemplate_InvalidStatmod(bytes32 statmodEntity);

  /**
   * @dev Check data validity before setting effect template
   */
  function verifiedSet(bytes32 applicationEntity, EffectTemplateData memory effectTemplateData) internal {
    // Verify lengths
    if (effectTemplateData.entities.length != effectTemplateData.values.length) {
      revert LibEffectTemplate_LengthMismatch();
    }
    // Verify statmods existence
    for (uint256 i; i < effectTemplateData.entities.length; i++) {
      bytes32 statmodEntity = effectTemplateData.entities[i];
      if (StatmodTopic.unwrap(StatmodBase.getStatmodTopic(statmodEntity)) == bytes32(0)) {
        revert LibEffectTemplate_InvalidStatmod(statmodEntity);
      }
    }
    // Set
    EffectTemplate.set(applicationEntity, effectTemplateData);
  }
}
