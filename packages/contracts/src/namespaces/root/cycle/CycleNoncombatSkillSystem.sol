// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { LibActiveCombat } from "../combat/LibActiveCombat.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibSkill } from "../skill/LibSkill.sol";
import { LibCycle } from "../cycle/LibCycle.sol";

contract CycleNoncombatSkillSystem is System {
  function castNoncombatSkill(bytes32 cycleEntity, bytes32 skillEntity) public {
    LibCycle.requireAccess(cycleEntity);

    LibSkill.requireNonCombatType(skillEntity);
    LibSkill.useSkill(cycleEntity, skillEntity, cycleEntity);
  }
}
