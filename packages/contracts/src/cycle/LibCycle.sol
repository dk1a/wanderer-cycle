// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { ActiveCycleComponent, ID as ActiveCycleComponentID } from "./ActiveCycleComponent.sol";
import { ActiveGuiseComponent, ID as ActiveGuiseComponentID } from "../guise/ActiveGuiseComponent.sol";
import { GuisePrototypeComponent, ID as GuisePrototypeComponentID } from "../guise/GuisePrototypeComponent.sol";

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibExperience } from "../charstat/LibExperience.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";
import { LibToken } from "../token/LibToken.sol";

// TODO imports for testing stuff, remove later
import { EffectSubSystem, ID as EffectSubSystemID } from "../effect/EffectSubSystem.sol";
import { getSkillProtoEntity } from "../skill/SkillPrototypeComponent.sol";
import { RandomEquipmentSubSystem, ID as RandomEquipmentSubSystemID } from "../loot/RandomEquipmentSubSystem.sol";

library LibCycle {
  using LibCharstat for LibCharstat.Self;
  using LibExperience for LibExperience.Self;

  error LibCycle__CycleIsAlreadyActive();
  error LibCycle__CycleNotActive();
  error LibCycle__InvalidGuiseProtoEntity();

  function initCycle(
    IWorld world,
    uint256 targetEntity,
    uint256 guiseProtoEntity
  ) internal returns (uint256 cycleEntity) {
    // cycleEntity is for all the in-cycle components (everything except activeCycle)
    cycleEntity = world.getUniqueEntityId();

    IUint256Component components = world.components();
    ActiveCycleComponent activeCycleComp = ActiveCycleComponent(getAddressById(components, ActiveCycleComponentID));
    ActiveGuiseComponent activeGuiseComp = ActiveGuiseComponent(getAddressById(components, ActiveGuiseComponentID));
    GuisePrototypeComponent guiseProtoComp = GuisePrototypeComponent(
      getAddressById(components, GuisePrototypeComponentID)
    );
    LibCharstat.Self memory charstat = LibCharstat.__construct(components, cycleEntity);

    // cycle must be inactive
    if (activeCycleComp.has(targetEntity)) {
      revert LibCycle__CycleIsAlreadyActive();
    }
    // guise prototype must exist
    if (!guiseProtoComp.has(guiseProtoEntity)) {
      revert LibCycle__InvalidGuiseProtoEntity();
    }

    // set active cycle
    activeCycleComp.set(targetEntity, cycleEntity);
    // set active guise
    activeGuiseComp.set(cycleEntity, guiseProtoEntity);
    // init exp
    charstat.exp.initExp();
    // init currents
    charstat.setFullCurrents();
    // claim initial cycle turns
    LibCycleTurns.claimTurns(components, cycleEntity);

    // TODO copy astral skills
    // TODO wheel
    // TODO wallet

    // TODO effect and loot for testing, remove later
    {
      EffectSubSystem effectSubSystem = EffectSubSystem(getAddressById(world.systems(), EffectSubSystemID));
      effectSubSystem.executeApply(cycleEntity, getSkillProtoEntity("Cleave"));

      RandomEquipmentSubSystem randomEquipmentSubSystem = RandomEquipmentSubSystem(
        getAddressById(world.systems(), RandomEquipmentSubSystemID)
      );
      randomEquipmentSubSystem.executeTyped(1, 123);
      randomEquipmentSubSystem.executeTyped(2, 456);
      randomEquipmentSubSystem.executeTyped(10, 789);
      randomEquipmentSubSystem.executeTyped(12, 101112);
    }

    return cycleEntity;
  }

  /// @dev Return `cycleEntity` if msg.sender is allowed to use it.
  /// Revert otherwise.
  ///
  /// Note on why getCycleEntity and a permission check are 1 method:
  /// Cycle systems take `wandererEntity` as the argument to simplify checking permissions,
  /// and then convert it to `cycleEntity`. If you don't need permission checks,
  /// you probably shouldn't need this method either, and should know cycle entities directly.
  function getCycleEntityPermissioned(
    IUint256Component components,
    uint256 wandererEntity
  ) internal view returns (uint256 cycleEntity) {
    // check permission
    LibToken.requireOwner(components, wandererEntity, msg.sender);
    // get cycle entity
    ActiveCycleComponent activeCycleComp = ActiveCycleComponent(getAddressById(components, ActiveCycleComponentID));
    if (!activeCycleComp.has(wandererEntity)) revert LibCycle__CycleNotActive();
    return activeCycleComp.getValue(wandererEntity);
  }
}
