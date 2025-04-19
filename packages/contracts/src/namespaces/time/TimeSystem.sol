// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { Duration, GenericDurationData } from "../duration/Duration.sol";
import { EffectDuration } from "../effect/LibEffect.sol";
import { SkillCooldown } from "../skill/codegen/tables/SkillCooldown.sol";

// TODO this has somewhat circular dependencies, consider a more dynamic system where admin can add tableIds
contract TimeSystem is System {
  function decreaseApplications(bytes32 targetEntity, GenericDurationData memory duration) public {
    ResourceId[2] memory durationTableIds = [EffectDuration._tableId, SkillCooldown._tableId];
    for (uint256 i; i < durationTableIds.length; i++) {
      Duration.decreaseApplications(durationTableIds[i], targetEntity, duration);
    }
  }
}
