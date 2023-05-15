// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import { Statmod, Element, EL_L } from "../statmod/Statmod.sol";
import { Topics } from "./Topics.sol";
import { LibExperience, PStat, PS_L } from "./LibExperience.sol";
import { LifeCurrentComponent, ID as LifeCurrentComponentID } from "./LifeCurrentComponent.sol";
import { ManaCurrentComponent, ID as ManaCurrentComponentID } from "./ManaCurrentComponent.sol";

library LibCharstat {}
