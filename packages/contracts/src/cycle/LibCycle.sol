// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { ActiveCycleComponent, ID as ActiveCycleComponentID } from "./ActiveCycleComponent.sol";
import { ActiveGuiseComponent, ID as ActiveGuiseComponentID } from "../guise/ActiveGuiseComponent.sol";
import { GuisePrototypeComponent, ID as GuisePrototypeComponentID } from "../guise/GuisePrototypeComponent.sol";

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibExperience } from "../charstat/LibExperience.sol";
import { LibCycleTurns } from "./LibCycleTurns.sol";

library LibCycle {
  using LibCharstat for LibCharstat.Self;
  using LibExperience for LibExperience.Self;

  error LibCycle__CycleIsAlreadyActive();
  error LibCycle__InvalidGuiseProtoEntity();

  struct Self {
    IUint256Component components;
    ActiveCycleComponent activeCycleComp;
    ActiveGuiseComponent activeGuiseComp;
    GuisePrototypeComponent guiseProtoComp;
    LibCharstat.Self charstat;
    uint256 targetEntity;
  }

  function __construct(
    IUint256Component components,
    uint256 targetEntity
  ) internal view returns (Self memory) {
    return Self({
      components: components,
      activeCycleComp: ActiveCycleComponent(getAddressById(components, ActiveCycleComponentID)),
      activeGuiseComp: ActiveGuiseComponent(getAddressById(components, ActiveGuiseComponentID)),
      guiseProtoComp: GuisePrototypeComponent(getAddressById(components, GuisePrototypeComponentID)),
      charstat: LibCharstat.__construct(components, targetEntity),
      targetEntity: targetEntity
    });
  }

  function initCycle(
    Self memory __self,
    uint256 cycleEntity,
    uint256 guiseProtoEntity
  ) internal {
    // cycle must be inactive
    if (__self.activeCycleComp.has(__self.targetEntity)) {
      revert LibCycle__CycleIsAlreadyActive();
    }
    // guise prototype must exist
    if (!__self.guiseProtoComp.has(guiseProtoEntity)) {
      revert LibCycle__InvalidGuiseProtoEntity();
    }

    // set active cycle
    __self.activeCycleComp.set(__self.targetEntity, cycleEntity);
    // set active guise
    __self.activeGuiseComp.set(__self.targetEntity, guiseProtoEntity);
    // init exp
    __self.charstat.exp.initExp();
    // init currents
    __self.charstat.setFullCurrents();
    // claim initial cycle turns
    LibCycleTurns.claimTurns(__self.components, cycleEntity);

    // TODO copy astral skills
    // TODO wheel
    // TODO wallet
  }
}