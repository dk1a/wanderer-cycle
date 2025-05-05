// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { Duration, GenericDurationData } from "../duration/Duration.sol";
import { EffectDuration } from "../effect/LibEffect.sol";
import { SkillCooldown } from "../skill/codegen/tables/SkillCooldown.sol";

contract TimeSystem is System {
  function passTurns(bytes32 targetEntity, uint256 timeValue) public {
    if (timeValue == 0) return;
    // Decrease turn durations
    _decreaseApplications(targetEntity, GenericDurationData({ timeId: "turn", timeValue: timeValue }));
    // Exhaust all round durations (1 turn = infinite rounds)
    _decreaseApplications(targetEntity, GenericDurationData({ timeId: "round", timeValue: type(uint256).max }));
  }

  function passRounds(bytes32 targetEntity, uint256 timeValue) public {
    // Decrease round durations
    _decreaseApplications(targetEntity, GenericDurationData({ timeId: "round", timeValue: timeValue }));
    // Persisten rounds persist through any `passTurn` calls
    _decreaseApplications(targetEntity, GenericDurationData({ timeId: "round_persistent", timeValue: timeValue }));
  }

  // TODO this has somewhat circular dependencies, consider a more dynamic system where admin can add tableIds
  function _decreaseApplications(bytes32 targetEntity, GenericDurationData memory duration) internal {
    ResourceId[2] memory durationTableIds = [EffectDuration._tableId, SkillCooldown._tableId];
    for (uint256 i; i < durationTableIds.length; i++) {
      Duration.decreaseApplications(durationTableIds[i], targetEntity, duration);
    }
  }
}
