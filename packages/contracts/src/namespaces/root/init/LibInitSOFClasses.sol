// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { entitySystem } from "../../evefrontier/codegen/systems/EntitySystemLib.sol";

import { wandererSpawnSystem } from "../../wanderer/codegen/systems/WandererSpawnSystemLib.sol";
import { permSkillSystem } from "../../wanderer/codegen/systems/PermSkillSystemLib.sol";
import { charstatSystem } from "../../charstat/codegen/systems/CharStatSystemLib.sol";
import { effectSystem } from "../../effect/codegen/systems/EffectSystemLib.sol";
import { skillSystem } from "../../skill/codegen/systems/SkillSystemLib.sol";
import { learnSkillSystem } from "../../skill/codegen/systems/LearnSkillSystemLib.sol";
import { timeSystem } from "../../time/codegen/systems/TimeSystemLib.sol";
import { combatSystem } from "../../combat/codegen/systems/CombatSystemLib.sol";
import { equipmentSystem } from "../../equipment/codegen/systems/EquipmentSystemLib.sol";
import { equipmentSlotSystem } from "../../equipment/codegen/systems/EquipmentSlotSystemLib.sol";
import { randomEquipmentSystem } from "../../loot/codegen/systems/RandomEquipmentSystemLib.sol";
import { randomMapSystem } from "../../loot/codegen/systems/RandomMapSystemLib.sol";

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
    // These classes are reserved for testing purposes
    _add("empty");
    _add("test");
    _add("test2");

    _add("statmod");
    _add("skill", _skillSystems());
    _add("combat", _combatSystems());
    _add("affix");
    _add("equipment", _equipmentSystems());
    _add("equipment_slot", _equipmentSlotSystems());
    _add("map", _mapSystems());

    _add("cycle", _mergeArrays(_cycleAuxSystems(), _cycleSystems()));
    // TODO refine this when encounters are finalized
    _add("cycle_encounter", _mergeArrays(_cycleAuxSystems(), _cycleSystems()));

    _add("wanderer", _wandererSystems());
  }

  function _skillSystems() internal pure returns (ResourceId[] memory systemIds) {
    systemIds = new ResourceId[](2);
    systemIds[0] = skillSystem.toResourceId();
    systemIds[1] = learnSkillSystem.toResourceId();
  }

  function _combatSystems() internal pure returns (ResourceId[] memory systemIds) {
    systemIds = new ResourceId[](1);
    systemIds[0] = combatSystem.toResourceId();
  }

  function _equipmentSystems() internal pure returns (ResourceId[] memory systemIds) {
    systemIds = new ResourceId[](2);
    systemIds[0] = equipmentSystem.toResourceId();
    systemIds[1] = randomEquipmentSystem.toResourceId();
  }

  function _equipmentSlotSystems() internal pure returns (ResourceId[] memory systemIds) {
    systemIds = new ResourceId[](2);
    systemIds[0] = equipmentSlotSystem.toResourceId();
    systemIds[1] = equipmentSystem.toResourceId();
  }

  function _mapSystems() internal pure returns (ResourceId[] memory systemIds) {
    systemIds = new ResourceId[](1);
    systemIds[0] = randomMapSystem.toResourceId();
  }

  function _cycleAuxSystems() internal pure returns (ResourceId[] memory systemIds) {
    systemIds = new ResourceId[](7);
    systemIds[0] = charstatSystem.toResourceId();
    systemIds[1] = effectSystem.toResourceId();
    systemIds[2] = skillSystem.toResourceId();
    systemIds[3] = learnSkillSystem.toResourceId();
    systemIds[4] = timeSystem.toResourceId();
    systemIds[5] = combatSystem.toResourceId();
    systemIds[6] = equipmentSystem.toResourceId();
  }

  function _cycleSystems() internal pure returns (ResourceId[] memory systemIds) {
    systemIds = new ResourceId[](11);
    systemIds[0] = cycleActivateCombatSystem.toResourceId();
    systemIds[1] = cycleClaimTurnsSystem.toResourceId();
    systemIds[2] = cycleCombatRewardSystem.toResourceId();
    systemIds[3] = cycleCombatSystem.toResourceId();
    systemIds[4] = cycleControlSystem.toResourceId();
    systemIds[5] = cycleEquipmentSystem.toResourceId();
    systemIds[6] = cycleLearnSkillSystem.toResourceId();
    systemIds[7] = cycleNoncombatSkillSystem.toResourceId();
    systemIds[8] = cyclePassTurnSystem.toResourceId();
    systemIds[9] = initCycleSystem.toResourceId();
    systemIds[10] = wandererSpawnSystem.toResourceId();
  }

  function _wandererSystems() internal pure returns (ResourceId[] memory systemIds) {
    systemIds = new ResourceId[](4);
    systemIds[0] = wandererSpawnSystem.toResourceId();
    systemIds[1] = cycleControlSystem.toResourceId();
    systemIds[2] = permSkillSystem.toResourceId();
    systemIds[3] = learnSkillSystem.toResourceId();
  }

  function _add(string memory name) internal {
    bytes32 classId = bytes32(entitySystem.registerClass(new ResourceId[](0)));
    SOFClassName.set(classId, name);
  }

  function _add(string memory name, ResourceId[] memory systemIds) internal {
    bytes32 classId = bytes32(entitySystem.registerClass(systemIds));
    SOFClassName.set(classId, name);
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
