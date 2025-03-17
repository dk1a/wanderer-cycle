// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AffixPartId, Affix, AffixData, AffixPrototype } from "../../affix/LibPickAffix.sol";
import { CycleCombatRReq, CycleCombatRReqData, BossesDefeated, FromMap, MapTypeComponent, LootAffixes } from "../codegen/index.sol";

import { PStat_length } from "../../../CustomTypes.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibRNG } from "../rng/LibRNG.sol";
import { MapTypes, MapType } from "../map/MapType.sol";

library LibCycleCombatRewardRequest {
  error LibCycleCombatRewardRequest_EntityMismatch();
  error LibCycleCombatRewardRequest_EncounterWithoutMap(bytes32 encounterEntity);
  error LibCycleCombatRewardRequest_InvalidMapType(bytes32 mapEntity, MapType mapType);

  /// @dev Creates a pending request
  function requestReward(bytes32 cycleEntity, bytes32 encounterEntity) internal {
    // Get and verify the encounter's map
    bytes32 mapEntity = FromMap.get(encounterEntity);
    if (mapEntity == bytes32(0)) {
      revert LibCycleCombatRewardRequest_EncounterWithoutMap(encounterEntity);
    }
    MapType mapType = MapTypeComponent.get(mapEntity);
    if (MapType.unwrap(mapType) == bytes32(0)) {
      revert LibCycleCombatRewardRequest_InvalidMapType(mapEntity, mapType);
    }

    // Request a reward, after a few blocks it can be claimed via `CycleCombatRewardSystem`
    bytes32 requestId = LibRNG.requestRandomness(cycleEntity);

    CycleCombatRReq.set(
      requestId,
      CycleCombatRReqData({
        mapEntity: mapEntity,
        connection: LibCharstat.getConnection(cycleEntity),
        fortune: LibCharstat.getFortune(cycleEntity),
        winnerPStat: LibCharstat.getPStats(cycleEntity),
        loserPStat: LibCharstat.getPStats(encounterEntity)
      })
    );
  }

  /// @dev Verifies and removes the pending request, then returns the calculated reward
  function popReward(
    bytes32 cycleEntity,
    bytes32 requestId
  ) internal returns (uint256 randomness, uint32[PStat_length] memory exp, uint32 lootIlvl, uint256 lootCount) {
    // Reverts if getting randomness too early or too late
    // TODO ability to cancel request that's too late so they don't endlessly accumulate? or remove the limit
    randomness = LibRNG.getRandomness(cycleEntity, requestId);
    LibRNG.removeRequest(cycleEntity, requestId);

    CycleCombatRReqData memory req = CycleCombatRReq.get(requestId);
    MapType mapType = MapTypeComponent.get(req.mapEntity);

    exp = _getExpReward(randomness, req);
    (lootIlvl, lootCount) = _getLootReward(randomness, req);

    // Extra boss rewards
    if (mapType == MapTypes.CYCLE_BOSS) {
      lootCount += 2;

      BossesDefeated.push(cycleEntity, req.mapEntity);
    }
  }

  function _getExpReward(
    uint256 randomness,
    CycleCombatRReqData memory req
  ) private pure returns (uint32[PStat_length] memory exp) {
    for (uint256 i; i < PStat_length; i++) {
      // Initial exp is connection + loser's stats
      exp[i] = req.connection + req.loserPStat[i];

      if (req.winnerPStat[i] > req.loserPStat[i]) {
        // Easy win may reduce exp by up to stat diff
        uint32 range = req.winnerPStat[i] - req.loserPStat[i];
        uint256 iterRandomness = uint256(keccak256(abi.encode("subExp", i, randomness)));
        uint32 subExp = uint32(iterRandomness % range);
        if (subExp > exp[i]) {
          // Exp reward can be 0, but not negative
          exp[i] = 0;
        } else {
          exp[i] -= subExp;
        }
      } else if (req.winnerPStat[i] < req.loserPStat[i]) {
        // Hard win may increase exp by up to stat diff
        uint32 range = req.loserPStat[i] - req.winnerPStat[i];
        uint256 iterRandomness = uint256(keccak256(abi.encode("addExp", i, randomness)));
        uint32 addExp = uint32(iterRandomness % range);
        exp[i] += addExp;
      }
    }
  }

  function _getLootReward(
    uint256 randomness,
    CycleCombatRReqData memory req
  ) private view returns (uint32 ilvl, uint256 count) {
    randomness = uint256(keccak256(abi.encode(keccak256("_getLootIlvlReward"), randomness)));

    // accumulatedFortune is fortune + affix tiers, it can improve the reward
    uint256 accumulatedFortune = req.fortune;

    bytes32[] memory affixes = LootAffixes.get(req.mapEntity);
    for (uint256 i; i < affixes.length; i++) {
      AffixData memory affix = Affix.get(affixes[i]);

      if (affix.partId == AffixPartId.IMPLICIT) {
        ilvl += affix.value;
      } else {
        uint32 tier = AffixPrototype.getAffixTier(affix.affixPrototypeEntity);
        accumulatedFortune += tier;
      }
    }

    while (accumulatedFortune > 0) {
      // TODO less hardcode, more generalization; and add comments, this looks confusing
      if (randomness % accumulatedFortune < 8) {
        count++;
      }

      if (accumulatedFortune > 8) {
        accumulatedFortune -= 8;
      } else {
        accumulatedFortune = 0;
      }
    }
    return (ilvl, count);
  }
}
