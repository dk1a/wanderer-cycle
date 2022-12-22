// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";
import {
  EffectPrototype,
  EffectPrototypeComponent,
  ID as EffectPrototypeComponentID
} from "./EffectPrototypeComponent.sol";
import { StatmodPrototypeComponent, ID as StatmodPrototypeComponentID } from "../statmod/StatmodPrototypeComponent.sol";

library LibEffectPrototype {
  error LibEffectPrototype__InvalidStatmod();

  /**
   * @dev Check data validity before setting effect prototype
   */
  function verifiedSet(
    IUint256Component components,
    uint256 effectProtoEntity,
    EffectPrototype memory effectProto
  ) internal {
    StatmodPrototypeComponent statmodComp
      = StatmodPrototypeComponent(getAddressById(components, StatmodPrototypeComponentID));
    EffectPrototypeComponent effectProtoComp
      = EffectPrototypeComponent(getAddressById(components, EffectPrototypeComponentID));

    // verify
    for (uint256 i; i < effectProto.statmods.length; i++) {
      if (!statmodComp.has(effectProto.statmods[i].statmodProtoEntity)) {
        revert LibEffectPrototype__InvalidStatmod();
      }
    }
    // set
    effectProtoComp.set(effectProtoEntity, effectProto);
  }
}