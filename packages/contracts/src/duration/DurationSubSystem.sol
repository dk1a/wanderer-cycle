// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { ScopedDurationSubsystem, ScopedDuration } from "@dk1a/solecslib/contracts/duration/ScopedDurationSubsystem.sol";

import { DurationScopeComponent, ID as DurationScopeComponentID } from "./DurationScopeComponent.sol";
import { DurationValueComponent, ID as DurationValueComponentID } from "./DurationValueComponent.sol";
import { DurationOnEndComponent, ID as DurationOnEndComponentID, SystemCallback } from "./DurationOnEndComponent.sol";

uint256 constant ID = uint256(keccak256("system.Duration"));

/**
 * @title Scoped duration time manager.
 */
contract DurationSubSystem is ScopedDurationSubsystem {
  constructor(
    IWorld _world,
    address _components
  )
    ScopedDurationSubsystem(
      _world,
      _components,
      DurationScopeComponentID,
      DurationValueComponentID,
      DurationOnEndComponentID
    )
  {}
}
