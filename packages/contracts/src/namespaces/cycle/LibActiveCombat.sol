// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ActiveCombat } from "./codegen/tables/ActiveCombat.sol";

library LibActiveCombat {
  error LibActiveCombat_CombatActive(bytes32 cycleEntity);
  error LibActiveCombat_CombatNotActive(bytes32 cycleEntity);

  function getCombatEntity(bytes32 cycleEntity) internal view returns (bytes32 combatEntity) {
    combatEntity = ActiveCombat.get(cycleEntity);
    if (combatEntity == bytes32(0)) {
      revert LibActiveCombat_CombatNotActive(cycleEntity);
    }
  }

  function requireNotActiveCombat(bytes32 cycleEntity) internal view {
    if (ActiveCombat.get(cycleEntity) != bytes32(0)) {
      revert LibActiveCombat_CombatActive(cycleEntity);
    }
  }

  function activateCombat(bytes32 cycleEntity, bytes32 combatEntity) internal {
    LibActiveCombat.requireNotActiveCombat(cycleEntity);

    ActiveCombat.set(cycleEntity, combatEntity);
  }

  function deactivateCombat(bytes32 cycleEntity) internal {
    bytes32 combatEntity = ActiveCombat.get(cycleEntity);
    if (combatEntity == bytes32(0)) {
      revert LibActiveCombat_CombatNotActive(cycleEntity);
    }

    ActiveCombat.deleteRecord(cycleEntity);
  }
}
