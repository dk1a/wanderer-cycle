// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { entitySystem } from "../../evefrontier/codegen/systems/EntitySystemLib.sol";

import { charstatSystem } from "../../charstat/codegen/systems/CharStatSystemLib.sol";
import { effectSystem } from "../../effect/codegen/systems/EffectSystemLib.sol";
import { skillSystem } from "../../skill/codegen/systems/SkillSystemLib.sol";
import { learnSkillSystem } from "../../skill/codegen/systems/LearnSkillSystemLib.sol";
import { timeSystem } from "../../time/codegen/systems/TimeSystemLib.sol";
import { combatSystem } from "../../combat/codegen/systems/CombatSystemLib.sol";
import { equipmentSystem } from "../../equipment/codegen/systems/EquipmentSystemLib.sol";

// Cycle systems
import { cycleActivateCombatSystem } from "../../cycle/codegen/systems/CycleActivateCombatSystemLib.sol";
import { cycleClaimTurnsSystem } from "../../cycle/codegen/systems/CycleClaimTurnsSystemLib.sol";
import { cycleCombatRewardSystem } from "../../cycle/codegen/systems/CycleCombatRewardSystemLib.sol";
import { cycleCombatSystem } from "../../cycle/codegen/systems/CycleCombatSystemLib.sol";
import { cycleControlSystem } from "../../cycle/codegen/systems/CycleControlSystemLib.sol";
import { cycleEquipmentSystem } from "../../cycle/codegen/systems/CycleEquipmentSystemLib.sol";
import { cycleLearnSkillSystem } from "../../cycle/codegen/systems/CycleLearnSkillSystemLib.sol";
import { cycleNoncombatSkillSystem } from "../../cycle/codegen/systems/CycleNoncombatSkillSystemLib.sol";
import { cyclePassTurnSystem } from "../../cycle/codegen/systems/CyclePassTurnSystemLib.sol";
import { initCycleSystem } from "../../cycle/codegen/systems/InitCycleSystemLib.sol";

import { SOFClassName } from "../../common/codegen/tables/SOFClassName.sol";

library LibInitSOFClasses {
  function init() internal {
    _empty();
    _combat();
    _cycle();
  }

  // The empty class is just for testing purposes
  function _empty() internal {
    bytes32 classId = bytes32(entitySystem.registerClass(new ResourceId[](0)));
    SOFClassName.set(classId, "empty");
  }

  function _combat() internal {
    ResourceId[] memory systemIds = new ResourceId[](1);
    systemIds[0] = combatSystem.toResourceId();

    bytes32 classId = bytes32(entitySystem.registerClass(systemIds));
    SOFClassName.set(classId, "combat");
  }

  function _cycle() internal {
    // TODO some of this, like charstat, probably shouldn't be scoped at all, and simply check the caller scope
    // Others may be better scoped to object, not class; or more custom access?
    // Only InitCycleSystem needs to actually instantiate objects
    ResourceId[] memory auxSystems = new ResourceId[](7);
    auxSystems[0] = charstatSystem.toResourceId();
    auxSystems[1] = effectSystem.toResourceId();
    auxSystems[2] = skillSystem.toResourceId();
    auxSystems[3] = learnSkillSystem.toResourceId();
    auxSystems[4] = timeSystem.toResourceId();
    auxSystems[5] = combatSystem.toResourceId();
    auxSystems[6] = equipmentSystem.toResourceId();

    ResourceId[] memory cycleSystems = new ResourceId[](10);
    cycleSystems[0] = cycleActivateCombatSystem.toResourceId();
    cycleSystems[1] = cycleClaimTurnsSystem.toResourceId();
    cycleSystems[2] = cycleCombatRewardSystem.toResourceId();
    cycleSystems[3] = cycleCombatSystem.toResourceId();
    cycleSystems[4] = cycleControlSystem.toResourceId();
    cycleSystems[5] = cycleEquipmentSystem.toResourceId();
    cycleSystems[6] = cycleLearnSkillSystem.toResourceId();
    cycleSystems[7] = cycleNoncombatSkillSystem.toResourceId();
    cycleSystems[8] = cyclePassTurnSystem.toResourceId();
    cycleSystems[9] = initCycleSystem.toResourceId();

    bytes32 cycleClassId = bytes32(entitySystem.registerClass(_mergeArrays(cycleSystems, auxSystems)));
    SOFClassName.set(cycleClassId, "cycle");

    // TODO refine this when encounters are finalized
    bytes32 encounterClassId = bytes32(entitySystem.registerClass(_mergeArrays(cycleSystems, auxSystems)));
    SOFClassName.set(encounterClassId, "cycle_encounter");
  }

  function _mergeArrays(
    ResourceId[] memory a,
    ResourceId[] memory b
  ) internal pure returns (ResourceId[] memory result) {
    result = new ResourceId[](a.length + b.length);
    for (uint256 i; i < a.length; i++) {
      result[i] = a[i];
    }
    for (uint256 i; i < b.length; i++) {
      result[a.length + i] = b[i];
    }
    return result;
  }
}
