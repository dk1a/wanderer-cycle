// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";
import { Subsystem } from "@latticexyz/solecs/src/Subsystem.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";
import {
  EffectRemovability,
  EffectStatmod,
  EffectPrototype,
  EffectPrototypeComponent,
  ID as EffectPrototypeComponentID
} from "./EffectPrototypeComponent.sol";
import { AppliedEffectComponent, ID as AppliedEffectComponentID } from "./AppliedEffectComponent.sol";
import { Statmod } from "../statmod/Statmod.sol";
// duration
import {
  SystemCallback,
  ScopedDuration,
  DurationSubsystem,
  ID as DurationSubsystemID
} from "../duration/DurationSubsystem.sol";

/// @dev effectEntity = hashed(ID, target, prototype)
function getEffectEntity(uint256 targetEntity, uint256 protoEntity) pure returns (uint256) {
  return uint256(keccak256(abi.encode(ID, targetEntity, protoEntity)));
}

uint256 constant ID = uint256(keccak256("system.Effect"));

contract EffectSubsystem is Subsystem {
  error EffectSubsystem__InvalidProtoEntity();
  error EffectSubsystem__InvalidExecuteSelector();

  constructor(IWorld _world, address _components) Subsystem(_world, _components) {}

  function executeApplyTimed(
    uint256 targetEntity,
    uint256 protoEntity,
    ScopedDuration memory duration
  ) public onlyWriter {
    executeApply(targetEntity, protoEntity);

    // callback to remove the effect on duration end
    // TODO I think callbacks shouldn't be managed by DurationSubsystem after all
    // (it can lead to dangling callbacks, though it isn't critical cause there's no async)
    SystemCallback memory onEnd = SystemCallback({
      systemId: ID,
      args: abi.encode(this.executeRemove.selector, abi.encode(targetEntity, protoEntity))
    });

    // effect prototypes may be global, so applied entity is target-specific 
    uint256 appliedEntity = getEffectEntity(targetEntity, protoEntity);

    DurationSubsystem durationSubsystem = DurationSubsystem(getAddressById(world.systems(), DurationSubsystemID));
    durationSubsystem.executeIncrease(targetEntity, appliedEntity, duration, onEnd);
  }

  function executeApply(uint256 targetEntity, uint256 protoEntity) public onlyWriter {
    EffectPrototypeComponent protoComp = _protoComp();
    AppliedEffectComponent comp = _comp();
    // valid effect prototype required
    if (!protoComp.has(protoEntity)) {
      revert EffectSubsystem__InvalidProtoEntity();
    }

    EffectPrototype memory effect = protoComp.getValue(protoEntity);
    // effect prototypes may be global, so applied entity is target-specific 
    uint256 appliedEntity = getEffectEntity(targetEntity, protoEntity);

    Statmod.Self memory statmod = Statmod.__construct(components, targetEntity);
    if (!comp.has(appliedEntity)) {
      // set applied effect data
      // (this is to avoid statmod leaks on effect removal, in case prototype changes)
      comp.set(appliedEntity, effect);
      // increase statmods
      // TODO figure out what to do if statmods are empty
      for (uint256 i; i < effect.statmods.length; i++) {
        Statmod.increase(
          statmod,
          effect.statmods[i].statmodProtoEntity,
          effect.statmods[i].value
        );
      }
    }
    // TODO extend/refresh existing effect by applying it again
  }

  function executeRemove(uint256 targetEntity, uint256 protoEntity) public onlyWriter {
    AppliedEffectComponent comp = _comp();
    uint256 appliedEntity = getEffectEntity(targetEntity, protoEntity);
    if (!comp.has(appliedEntity)) {
      // nothing to remove
      return;
    }
    // get and remove applied effect data
    // (prototype isn't used in removal, so its statmods can change without leaking)
    EffectPrototype memory effect = comp.getValue(appliedEntity);
    comp.remove(appliedEntity);
    // subtract statmods
    Statmod.Self memory statmod = Statmod.__construct(components, targetEntity);
    for (uint256 i; i < effect.statmods.length; i++) {
      Statmod.decrease(
        statmod,
        effect.statmods[i].statmodProtoEntity,
        effect.statmods[i].value
      );
    }
  }

  /*//////////////////////////////////////////////////////////////
                                READ
  //////////////////////////////////////////////////////////////*/

  /**
   * @dev Returns true if `protoEntity` is an effect prototype
   */
  function isEffectPrototype(uint256 protoEntity) public view returns (bool) {
    return _protoComp().has(protoEntity);
  }

  /**
   * @dev Returns true if `targetEntity` has an ongoing effect for `protoEntity`.
   */
  function has(
    uint256 targetEntity,
    uint256 protoEntity
  ) public view returns (bool) {
    return _comp().has(getEffectEntity(targetEntity, protoEntity));
  }

  /*//////////////////////////////////////////////////////////////
                              INTERNAL
  //////////////////////////////////////////////////////////////*/

  function _execute(bytes memory args) internal override returns (bytes memory) {
    (bytes4 executeSelector, bytes memory innerArgs) = abi.decode(args, (bytes4, bytes));

    if (executeSelector == this.executeRemove.selector) {
      (uint256 targetEntity, uint256 protoEntity) = abi.decode(innerArgs, (uint256, uint256));
      executeRemove(targetEntity, protoEntity);
      return '';

    } else if (executeSelector == this.executeApply.selector) {
      (uint256 targetEntity, uint256 protoEntity) = abi.decode(innerArgs, (uint256, uint256));
      executeApply(targetEntity, protoEntity);
      return '';

    } else if (executeSelector == this.executeApplyTimed.selector) {
      (
        uint256 targetEntity,
        uint256 protoEntity,
        ScopedDuration memory duration
      ) = abi.decode(innerArgs, (uint256, uint256, ScopedDuration));
      executeApplyTimed(targetEntity, protoEntity, duration);
      return '';

    } else {
      revert EffectSubsystem__InvalidExecuteSelector();
    }
  }

  /// @dev Get the prototype component.
  function _protoComp() internal view returns (EffectPrototypeComponent) {
    return EffectPrototypeComponent(getAddressById(components, EffectPrototypeComponentID));
  }

  /// @dev Get the applied component.
  function _comp() internal view returns (AppliedEffectComponent) {
    return AppliedEffectComponent(getAddressById(components, AppliedEffectComponentID));
  }
}