// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { ActiveCycleComponent, ID as ActiveCycleComponentID } from "./ActiveCycleComponent.sol";
import { ActiveGuiseComponent, ID as ActiveGuiseComponentID } from "../guise/ActiveGuiseComponent.sol";
import { GuisePrototypeComponent, ID as GuisePrototypeComponentID } from "../guise/GuisePrototypeComponent.sol";

import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibExperience } from "../charstat/LibExperience.sol";

library LibCycle {
  using LibCharstat for LibCharstat.Self;
  using LibExperience for LibExperience.Self;

  error LibCycle__CycleIsAlreadyActive();
  error LibCycle__InvalidGuiseProtoEntity();

  struct Self {
    ActiveCycleComponent activeCycleComp;
    ActiveGuiseComponent activeGuiseComp;
    GuisePrototypeComponent guiseProtoComp;
    LibCharstat.Self charstat;
    uint256 targetEntity;
  }

  function __construct(
    IUint256Component registry,
    uint256 targetEntity
  ) internal view returns (Self memory) {
    return Self({
      activeCycleComp: ActiveCycleComponent(getAddressById(registry, ActiveCycleComponentID)),
      activeGuiseComp: ActiveGuiseComponent(getAddressById(registry, ActiveGuiseComponentID)),
      guiseProtoComp: GuisePrototypeComponent(getAddressById(registry, GuisePrototypeComponentID)),
      charstat: LibCharstat.__construct(registry, targetEntity),
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

    // TODO turns
    // TODO copy astral skills
    // TODO wheel
    // TODO wallet
  }
}