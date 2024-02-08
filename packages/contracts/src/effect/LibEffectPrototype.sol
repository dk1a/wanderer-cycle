// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { EffectTemplate, EffectTemplateData, StatmodBase } from "../codegen/index.sol";
import { StatmodTopic } from "../statmod/StatmodTopic.sol";

library LibEffectPrototype {
  error LibEffectPrototype_LengthMismatch();
  error LibEffectPrototype_InvalidStatmod();

  /**
   * @dev Check data validity before setting effect prototype
   */
  function verifiedSet(bytes32 effectProtoEntity, EffectTemplateData memory effectTemplateData) internal {
    // verify lengths
    if (effectTemplateData.entities.length != effectTemplateData.values.length) {
      revert LibEffectPrototype_LengthMismatch();
    }
    // verify statmods existence
    for (uint256 i; i < effectTemplateData.entities.length; i++) {
      if (StatmodTopic.unwrap(StatmodBase.getStatmodTopic(effectTemplateData.entities[i])) == bytes32(0)) {
        revert LibEffectPrototype_InvalidStatmod();
      }
    }
    // set
    EffectTemplate.set(effectProtoEntity, effectTemplateData);
  }
}
