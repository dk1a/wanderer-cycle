// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { StatmodBase } from "../statmod/codegen/index.sol";
import { EffectTemplate, EffectTemplateData } from "./codegen/index.sol";
import { StatmodTopic } from "../statmod/StatmodTopic.sol";

contract EffectTemplateSystem is System {
  error EffectTemplateSystem_LengthMismatch();
  error EffectTemplateSystem_InvalidStatmod(bytes32 statmodEntity);

  /**
   * @dev Check data validity before setting effect template
   */
  function setEffectTemplate(bytes32 applicationEntity, EffectTemplateData memory effectTemplateData) public {
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
}
