// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { Duration, GenericDurationData } from "../duration/Duration.sol";
import { EffectDuration } from "../effect/LibEffect.sol";
import { SkillCooldown } from "./codegen/index.sol";

library LibTime {
  function decreaseApplications(bytes32 targetEntity, GenericDurationData memory duration) internal {
    ResourceId[2] memory durationTableIds = [EffectDuration._tableId, SkillCooldown._tableId];
    for (uint256 i; i < durationTableIds.length; i++) {
      Duration.decreaseApplications(durationTableIds[i], targetEntity, duration);
    }
  }
}
