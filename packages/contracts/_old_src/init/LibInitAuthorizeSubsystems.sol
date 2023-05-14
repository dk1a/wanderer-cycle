// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IOwnableWritable } from "solecs/interfaces/IOwnableWritable.sol";
import { getAddressById } from "solecs/utils.sol";

import { ID as DurationSubSystemID } from "../duration/DurationSubSystem.sol";
import { ID as EffectSubSystemID } from "../effect/EffectSubSystem.sol";
import { ID as EquipmentSubSystemID } from "../equipment/EquipmentSubSystem.sol";
import { ID as CombatSubSystemID } from "../combat/CombatSubSystem.sol";
import { ID as WNFTSystemID } from "../token/WNFTSystem.sol";
import { ID as CycleCombatSystemID } from "../cycle/CycleCombatSystem.sol";
import { ID as PassCycleTurnSystemID } from "../cycle/PassCycleTurnSystem.sol";
import { ID as LearnCycleSkillSystemID } from "../cycle/LearnCycleSkillSystem.sol";
import { ID as PermSkillSystemID } from "../wanderer/PermSkillSystem.sol";
import { ID as RandomEquipmentSubSystemID } from "../loot/RandomEquipmentSubSystem.sol";
import { ID as NoncombatSkillSystemID } from "../skill/NoncombatSkillSystem.sol";

import { ID as WandererSpawnSystemID } from "../wanderer/WandererSpawnSystem.sol";
import { ID as StartCycleSystemID } from "../cycle/StartCycleSystem.sol";
import { ID as CycleActivateCombatSystemID } from "../cycle/CycleActivateCombatSystem.sol";
import { ID as CycleCombatRewardSystemID } from "../cycle/CycleCombatRewardSystem.sol";
import { ID as CycleEquipmentSystemID } from "../cycle/CycleEquipmentSystem.sol";

library LibInitAuthorizeSubsystems {
  function init(IWorld world) internal {
    IUint256Component systems = world.systems();
    IOwnableWritable subsystem;
    address writer;

    // Duration -> Effect
    writer = getAddressById(systems, DurationSubSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubSystemID));
    subsystem.authorizeWriter(writer);

    // Effect -> Duration
    writer = getAddressById(systems, EffectSubSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, DurationSubSystemID));
    subsystem.authorizeWriter(writer);

    // Equipment -> Effect
    writer = getAddressById(systems, EquipmentSubSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubSystemID));
    subsystem.authorizeWriter(writer);

    // Combat -> Duration, Effect
    writer = getAddressById(systems, CombatSubSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, DurationSubSystemID));
    subsystem.authorizeWriter(writer);
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubSystemID));
    subsystem.authorizeWriter(writer);

    // NoncombatSkill -> Duration, Effect
    writer = getAddressById(systems, NoncombatSkillSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, DurationSubSystemID));
    subsystem.authorizeWriter(writer);
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubSystemID));
    subsystem.authorizeWriter(writer);

    // WandererSpawn -> WNFT, Effect
    writer = getAddressById(systems, WandererSpawnSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, WNFTSystemID));
    subsystem.authorizeWriter(writer);
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubSystemID));
    subsystem.authorizeWriter(writer);
    // TODO for testing, remove later (see LibCycle)
    subsystem = IOwnableWritable(getAddressById(systems, RandomEquipmentSubSystemID));
    subsystem.authorizeWriter(writer);

    // StartCycle -> Effect
    writer = getAddressById(systems, StartCycleSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubSystemID));
    subsystem.authorizeWriter(writer);
    // TODO for testing, remove later (see LibCycle)
    subsystem = IOwnableWritable(getAddressById(systems, RandomEquipmentSubSystemID));
    subsystem.authorizeWriter(writer);

    // CycleActivateCombat -> Effect, Combat
    writer = getAddressById(systems, CycleActivateCombatSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubSystemID));
    subsystem.authorizeWriter(writer);
    subsystem = IOwnableWritable(getAddressById(systems, CombatSubSystemID));
    subsystem.authorizeWriter(writer);

    // CycleCombat -> Combat
    writer = getAddressById(systems, CycleCombatSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, CombatSubSystemID));
    subsystem.authorizeWriter(writer);

    // CycleCombatReward -> RandomEquipment
    writer = getAddressById(systems, CycleCombatRewardSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, RandomEquipmentSubSystemID));
    subsystem.authorizeWriter(writer);

    // CycleEquipment -> Equipment
    writer = getAddressById(systems, CycleEquipmentSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, EquipmentSubSystemID));
    subsystem.authorizeWriter(writer);

    // PassCycleTurn -> Duration
    writer = getAddressById(systems, PassCycleTurnSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, DurationSubSystemID));
    subsystem.authorizeWriter(writer);

    // LearnCycleSkill -> Effect
    writer = getAddressById(systems, LearnCycleSkillSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubSystemID));
    subsystem.authorizeWriter(writer);

    // PermSkill -> Effect
    writer = getAddressById(systems, PermSkillSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubSystemID));
    subsystem.authorizeWriter(writer);
  }
}
