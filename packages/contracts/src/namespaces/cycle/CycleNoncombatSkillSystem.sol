// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { skillSystem } from "../skill/codegen/systems/SkillSystemLib.sol";

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibSkill } from "../skill/LibSkill.sol";
import { LibCycle } from "../cycle/LibCycle.sol";
import { LibActiveCombat } from "./LibActiveCombat.sol";

contract CycleNoncombatSkillSystem is System {
  function castNoncombatSkill(bytes32 cycleEntity, bytes32 skillEntity) public {
    LibCycle.requireAccess(cycleEntity);

    LibSkill.requireNonCombatType(skillEntity);
    skillSystem.useSkill(cycleEntity, skillEntity, cycleEntity);
  }
}
