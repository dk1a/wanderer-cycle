// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ActiveCombat, ActiveCombatData } from "./codegen/tables/ActiveCombat.sol";

/**
 * Requirements and updates of ActiveCombat table only.
 * Does not account for any other combat interactions!
 */
library LibActiveCombat {
  error LibActiveCombat_CombatActive(bytes32 initiatorEntity);
  error LibActiveCombat_CombatNotActive(bytes32 initiatorEntity);
  error LibActiveCombat_CombatActiveForDifferentRetaliator(
    bytes32 initiatorEntity,
    bytes32 retaliatorEntity,
    bytes32 storedRetaliatorEntity
  );
  error LibActiveCombat_RoundsOverMax(bytes32 initiatorEntity, bytes32 retaliatorEntity);

  function getRetaliatorEntity(bytes32 initiatorEntity) internal view returns (bytes32 retaliatorEntity) {
    retaliatorEntity = ActiveCombat.getRetaliatorEntity(initiatorEntity);
    if (retaliatorEntity == bytes32(0)) {
      revert LibActiveCombat_CombatNotActive(initiatorEntity);
    }
  }

  function requireActiveCombat(bytes32 initiatorEntity, bytes32 retaliatorEntity) internal view {
    bytes32 storedRetaliatorEntity = ActiveCombat.getRetaliatorEntity(initiatorEntity);
    if (storedRetaliatorEntity == bytes32(0)) {
      revert LibActiveCombat_CombatNotActive(initiatorEntity);
    }
    if (storedRetaliatorEntity != retaliatorEntity) {
      revert LibActiveCombat_CombatActiveForDifferentRetaliator(
        initiatorEntity,
        retaliatorEntity,
        storedRetaliatorEntity
      );
    }
  }

  function requireNotActiveCombat(bytes32 initiatorEntity) internal view {
    if (ActiveCombat.getRetaliatorEntity(initiatorEntity) != bytes32(0)) {
      revert LibActiveCombat_CombatActive(initiatorEntity);
    }
  }

  function activateCombat(bytes32 initiatorEntity, bytes32 retaliatorEntity, uint32 maxRounds) internal {
    LibActiveCombat.requireNotActiveCombat(initiatorEntity);

    ActiveCombat.set(
      initiatorEntity,
      ActiveCombatData({ retaliatorEntity: retaliatorEntity, roundsSpent: 0, roundsMax: maxRounds })
    );
  }

  function deactivateCombat(bytes32 initiatorEntity) internal {
    bytes32 storedRetaliatorEntity = ActiveCombat.getRetaliatorEntity(initiatorEntity);
    if (storedRetaliatorEntity == bytes32(0)) {
      revert LibActiveCombat_CombatNotActive(initiatorEntity);
    }

    ActiveCombat.deleteRecord(initiatorEntity);
  }

  function spendRound(
    bytes32 initiatorEntity,
    bytes32 retaliatorEntity
  ) internal returns (uint256 roundIndex, bool isFinalRound) {
    requireActiveCombat(initiatorEntity, retaliatorEntity);

    uint32 roundsSpent = ActiveCombat.getRoundsSpent(initiatorEntity);
    uint32 roundsMax = ActiveCombat.getRoundsMax(initiatorEntity);

    if (roundsSpent + 1 > roundsMax) {
      revert LibActiveCombat_RoundsOverMax(initiatorEntity, retaliatorEntity);
    }

    ActiveCombat.setRoundsSpent(initiatorEntity, roundsSpent + 1);

    roundIndex = roundsSpent;
    isFinalRound = roundsSpent + 1 == roundsMax;

    return (roundIndex, isFinalRound);
  }
}
