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
import { ID as RandomEquipmentSubSystemID } from "../loot/RandomEquipmentSubSystem.sol";

import { ID as WandererSpawnSystemID } from "../wanderer/WandererSpawnSystem.sol";
import { ID as CycleActivateCombatSystemID } from "../cycle/CycleActivateCombatSystem.sol";
import { ID as CycleCombatRewardSystemID } from "../cycle/CycleCombatRewardSystem.sol";

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

    // WandererSpawn -> WNFT
    writer = getAddressById(systems, WandererSpawnSystemID);
    subsystem = IOwnableWritable(getAddressById(systems, WNFTSystemID));
    subsystem.authorizeWriter(writer);
    // TODO for testing, remove later (see LibCycle)
    subsystem = IOwnableWritable(getAddressById(systems, EffectSubSystemID));
    subsystem.authorizeWriter(writer);
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
  }
}
