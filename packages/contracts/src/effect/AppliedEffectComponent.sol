// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

import { AbstractEffectComponent } from "./EffectPrototypeComponent.sol";

uint256 constant ID = uint256(keccak256("component.AppliedEffect"));

/**
 * @title Copy of EffectPrototype created during application.
 * @dev If EffectPrototype changes, any applied effects will hold the old value until reapplied
 * (this avoids statmod leaks)
 */
contract AppliedEffectComponent is AbstractEffectComponent {
  constructor(address world) AbstractEffectComponent(world, ID) {}
}