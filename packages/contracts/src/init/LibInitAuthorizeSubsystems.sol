// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IOwnableWritable } from "solecs/interfaces/IOwnableWritable.sol";
import { getAddressById } from "solecs/utils.sol";

import { ID as DurationSubsystemID } from "../duration/DurationSubsystem.sol";
import { ID as EffectSubsystemID } from "../effect/EffectSubsystem.sol";
import { ID as EquipmentSubsystemID } from "../equipment/EquipmentSubsystem.sol";
import { ID as CombatSubsystemID } from "../combat/CombatSubsystem.sol";
import { ID as WNFTSystemID } from "../token/WNFTSystem.sol";
import { ID as CycleCombatSystemID } from "../cycle/CycleCombatSystem.sol";
import { ID as RandomEquipmentSubsystemID } from "../loot/RandomEquipmentSubsystem.sol";

import { ID as WandererSpawnSystemID } from "../wanderer/WandererSpawnSystem.sol";
import { ID as CycleActivateCombatSystemID } from "../cycle/CycleActivateCombatSystem.sol";
import { ID as CycleCombatRewardSystemID } from "../cycle/CycleCombatRewardSystem.sol";

library LibInitAuthorizeSubsystems {
  function init(IWorld world) internal {
    IUint256Component systems = world.systems();
    IOwnableWritable subsystem;
    address writer;

    // Duration -> Effect
    writer = getAddressById(systems, DurationSubsystemID);
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubsystemID));
    subsystem.authorizeWriter(writer);

    // Effect -> Duration
    writer = getAddressById(systems, EffectSubsystemID);
    subsystem = IOwnableWritable(getAddressById(systems, DurationSubsystemID));
    subsystem.authorizeWriter(writer);

    // Equipment -> Effect
    writer = getAddressById(systems, EquipmentSubsystemID);
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubsystemID));
    subsystem.authorizeWriter(writer);

    // Combat -> Duration, Effect
    writer = getAddressById(systems, CombatSubsystemID);
    subsystem = IOwnableWritable(getAddressById(systems, DurationSubsystemID));
    subsystem.authorizeWriter(writer);
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubsystemID));
    subsystem.authorizeWriter(writer);

    // WandererSpawn -> WNFT
    writer = getAddressById(systems, WandererSpawnSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, WNFTSystemID));
    subsystem.authorizeWriter(writer);

    // CycleActivateCombat -> Effect, Combat
    writer = getAddressById(systems, CycleActivateCombatSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubsystemID));
    subsystem.authorizeWriter(writer);
    subsystem = IOwnableWritable(getAddressById(systems, CombatSubsystemID));
    subsystem.authorizeWriter(writer);

    // CycleCombat -> Combat
    writer = getAddressById(systems, CycleCombatSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, CombatSubsystemID));
    subsystem.authorizeWriter(writer);

    // CycleCombatReward -> RandomEquipment
    writer = getAddressById(systems, CycleCombatRewardSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, RandomEquipmentSubsystemID));
    subsystem.authorizeWriter(writer);
  }
}