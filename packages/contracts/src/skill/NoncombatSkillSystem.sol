// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";
import { Action, ActionType, CombatSubSystem, ID as CombatSubSystemID } from "../combat/CombatSubSystem.sol";
import { EffectSubSystem, ID as EffectSubSystemID } from "../effect/EffectSubSystem.sol";

import { MapPrototypes } from "../map/MapPrototypes.sol";
import { LibActiveCombat } from "../combat/LibActiveCombat.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibSkill } from "../skill/LibSkill.sol";
import { LibCycle } from "../cycle/LibCycle.sol";

uint256 constant ID = uint256(keccak256("system.NoncombatSkill"));

contract NoncombatSkillSystem is System {
  using LibSkill for LibSkill.Self;

  error NoncombatSkillSystem__Asd();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(uint256 cycleEntity, uint256 skillEntity) public {
    execute(abi.encode(cycleEntity, skillEntity));
  }

  function execute(bytes memory args) public override returns (bytes memory) {
    (uint256 cycleEntity, uint256 skillEntity) = abi.decode(args, (uint256, uint256));

    LibCycle.requirePermission(components, cycleEntity);

    LibSkill.Self memory libSkill = LibSkill.__construct(world, cycleEntity, skillEntity);
    libSkill.requireNonCombat();

    libSkill.useSkill(cycleEntity);

    return "";
  }
}
