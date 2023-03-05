// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { CycleCombatRewardRequestComponent, ID as CycleCombatRewardRequestComponentID } from "./CycleCombatRewardRequestComponent.sol";
import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";
import { Loot, LootComponent, ID as LootComponentID } from "../loot/LootComponent.sol";
import { AffixPrototypeComponent, ID as AffixPrototypeComponentID } from "../affix/AffixPrototypeComponent.sol";
import { CycleBossesDefeatedComponent, ID as CycleBossesDefeatedComponentID } from "./CycleBossesDefeatedComponent.sol";

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibRNG } from "../rng/LibRNG.sol";
import { AffixPartId } from "../affix/LibPickAffixes.sol";
import { PS_L } from "../charstat/ExperienceComponent.sol";
import { MapPrototypes } from "../map/MapPrototypes.sol";

struct CycleCombatRewardRequest {
  uint256 mapEntity;
  uint32 connection;
  uint32 fortune;
  uint32[PS_L] winnerPstats;
  uint32[PS_L] loserPstats;
}

library LibCycleCombatRewardRequest {
  using LibCharstat for LibCharstat.Self;

  error LibCycleCombatRewardRequest__EntityMismatch();
  error LibCycleCombatRewardRequest__UnknownMapPrototype();

  /// @dev Creates a pending request
  function requestReward(IWorld world, uint256 cycleEntity, uint256 retaliatorEntity) internal {
    IUint256Component components = world.components();
    FromPrototypeComponent fromProtoComp = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));
    // TODO see fromProto in `CycleActivateCombatSystem`
    uint256 mapEntity = fromProtoComp.getValue(retaliatorEntity);

    LibCharstat.Self memory charstatInitiator = LibCharstat.__construct(components, cycleEntity);
    LibCharstat.Self memory charstatRetaliator = LibCharstat.__construct(components, retaliatorEntity);
    // Request a reward, after a few blocks it can be claimed via `CycleCombatRewardSystem`
    uint256 requestId = LibRNG.requestRandomness(
      world,
      abi.encode(
        CycleCombatRewardRequest({
          mapEntity: mapEntity,
          connection: charstatInitiator.getConnection(),
          fortune: charstatInitiator.getFortune(),
          winnerPstats: charstatInitiator.getPStats(),
          loserPstats: charstatRetaliator.getPStats()
        })
      )
    );

    _comp(components).set(requestId, cycleEntity);
  }

  /// @dev Verifies and removes the pending request, then returns the calculated reward
  function popReward(
    IUint256Component components,
    uint256 cycleEntity,
    uint256 requestId
  ) internal returns (uint256 randomness, uint32[PS_L] memory exp, uint32 lootIlvl, uint256 lootCount) {
    removeReward(components, cycleEntity, requestId);

    // reverts if getting randomness too early or too late
    // TODO ability to cancel request that's too late so they don't endlessly accumulate? or remove the limit
    bytes memory data;
    (randomness, data) = LibRNG.getRandomness(components, requestId);

    CycleCombatRewardRequest memory req = abi.decode(data, (CycleCombatRewardRequest));

    FromPrototypeComponent fromProtoComp = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));
    uint256 mapProtoEntity = fromProtoComp.getValue(req.mapEntity);
    if (
      mapProtoEntity != MapPrototypes.GLOBAL_BASIC &&
      mapProtoEntity != MapPrototypes.GLOBAL_RANDOM &&
      mapProtoEntity != MapPrototypes.GLOBAL_CYCLE_BOSS
    ) {
      // TODO support for other map protos when they're added
      revert LibCycleCombatRewardRequest__UnknownMapPrototype();
    }

    exp = _getExpReward(randomness, req);
    (lootIlvl, lootCount) = _getLootReward(components, randomness, req);

    // extra boss rewards
    if (mapProtoEntity == MapPrototypes.GLOBAL_CYCLE_BOSS) {
      lootCount += 2;

      CycleBossesDefeatedComponent cycleBossesDefeated = CycleBossesDefeatedComponent(
        getAddressById(components, CycleBossesDefeatedComponentID)
      );
      cycleBossesDefeated.addItem(cycleEntity, req.mapEntity);
    }
  }

  /** Check permissions and remove the reward request */
  function removeReward(IUint256Component components, uint256 cycleEntity, uint256 requestId) internal {
    CycleCombatRewardRequestComponent comp = _comp(components);
    // `cycleEntity` must own the request
    if (cycleEntity != comp.getValue(requestId)) {
      revert LibCycleCombatRewardRequest__EntityMismatch();
    }
    comp.remove(requestId);
  }

  function _getExpReward(
    uint256 randomness,
    CycleCombatRewardRequest memory req
  ) private pure returns (uint32[PS_L] memory exp) {
    for (uint256 i; i < PS_L; i++) {
      // initial exp is connection + loser's stats
      exp[i] = req.connection + req.loserPstats[i];

      if (req.winnerPstats[i] > req.loserPstats[i]) {
        // easy win may reduce exp by up to stat diff
        uint32 range = req.winnerPstats[i] - req.loserPstats[i];
        uint256 iterRandomness = uint256(keccak256(abi.encode("subExp", i, randomness)));
        uint32 subExp = uint32(iterRandomness % range);
        if (subExp > exp[i]) {
          // exp reward can be 0, but not negative
          exp[i] = 0;
        } else {
          exp[i] -= subExp;
        }
      } else if (req.winnerPstats[i] < req.loserPstats[i]) {
        // hard win may increase exp by up to stat diff
        uint32 range = req.loserPstats[i] - req.winnerPstats[i];
        uint256 iterRandomness = uint256(keccak256(abi.encode("addExp", i, randomness)));
        uint32 addExp = uint32(iterRandomness % range);
        exp[i] += addExp;
      }
    }
  }

  function _getLootReward(
    IUint256Component components,
    uint256 randomness,
    CycleCombatRewardRequest memory req
  ) private view returns (uint32 ilvl, uint256 count) {
    randomness = uint256(keccak256(abi.encode(keccak256("_getLootIlvlReward"), randomness)));

    LootComponent lootComp = LootComponent(getAddressById(components, LootComponentID));
    AffixPrototypeComponent affixProtoComp = AffixPrototypeComponent(
      getAddressById(components, AffixPrototypeComponentID)
    );

    // accumulatedFortune is fortune + affix tiers, it can improve the reward
    uint256 accumulatedFortune = req.fortune;

    Loot memory loot = lootComp.getValue(req.mapEntity);
    for (uint256 i; i < loot.affixPartIds.length; i++) {
      if (loot.affixPartIds[i] == AffixPartId.IMPLICIT) {
        ilvl += uint32(loot.affixValues[i]);
      } else {
        uint256 tier = affixProtoComp.getValue(loot.affixProtoEntities[i]).tier;
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

  function _comp(IUint256Component components) internal view returns (CycleCombatRewardRequestComponent) {
    return CycleCombatRewardRequestComponent(getAddressById(components, CycleCombatRewardRequestComponentID));
  }
}
