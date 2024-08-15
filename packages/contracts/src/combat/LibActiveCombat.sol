// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ActiveCombat } from "../codegen/index.sol";

library LibActiveCombat {
  error LibActiveCombat_CombatActive();
  error LibActiveCombat_CombatNotActive();
  error LibActiveCombat_CombatActiveForDifferentRetaliator();
  error LibActiveCombat_RoundsOverMax();

  function getRetaliatorEntity(bytes32 initiatorEntity) internal view returns (bytes32 retaliatorEntity) {
    retaliatorEntity = ActiveCombat.getRetaliatorEntity(initiatorEntity);
    if (retaliatorEntity == bytes32(0)) {
      revert LibActiveCombat_CombatNotActive();
    }
  }

  function requireActiveCombat(bytes32 initiatorEntity, bytes32 retaliatorEntity) internal view {
    bytes32 storedRetaliatorEntity = ActiveCombat.getRetaliatorEntity(initiatorEntity);
    if (storedRetaliatorEntity == bytes32(0)) {
      revert LibActiveCombat_CombatNotActive();
    }
    if (storedRetaliatorEntity != retaliatorEntity) {
      revert LibActiveCombat_CombatActiveForDifferentRetaliator();
    }
  }

  function requireNotActiveCombat(bytes32 initiatorEntity) internal view {
    if (ActiveCombat.getRetaliatorEntity(initiatorEntity) != bytes32(0)) {
      revert LibActiveCombat_CombatActive();
    }
  }

  function spendRound(bytes32 initiatorEntity, bytes32 retaliatorEntity) public returns (bool isFinalRound) {
    requireActiveCombat(initiatorEntity, retaliatorEntity);

    uint32 roundsSpent = ActiveCombat.getRoundsSpent(initiatorEntity);
    uint32 roundsMax = ActiveCombat.getRoundsMax(initiatorEntity);

    if (roundsSpent + 1 > roundsMax) {
      revert LibActiveCombat_RoundsOverMax();
    }

    ActiveCombat.setRoundsSpent(initiatorEntity, roundsSpent + 1);

    return roundsSpent + 1 == roundsMax;
  }
}
