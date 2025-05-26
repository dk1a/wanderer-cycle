// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SmartObjectFramework } from "../evefrontier/SmartObjectFramework.sol";

import { PStat_length } from "../../CustomTypes.sol";
import { LifeCurrent } from "./codegen/tables/LifeCurrent.sol";
import { ManaCurrent } from "./codegen/tables/ManaCurrent.sol";
import { Experience } from "./codegen/tables/Experience.sol";

import { LibExperience } from "./LibExperience.sol";
import { LibCharstat } from "./LibCharstat.sol";

contract CharstatSystem is SmartObjectFramework {
  error CharstatSystem_ExpNotInitialized();

  function setLifeCurrent(bytes32 targetEntity, uint32 value) public context {
    _requireEntityLeaf(uint256(targetEntity));

    LifeCurrent.set(targetEntity, value);
  }

  function setManaCurrent(bytes32 targetEntity, uint32 value) public context {
    _requireEntityLeaf(uint256(targetEntity));

    ManaCurrent.set(targetEntity, value);
  }

  /**
   * @dev Set currents to max values
   */
  function setFullCurrents(bytes32 targetEntity) public context {
    _requireEntityLeaf(uint256(targetEntity));

    setLifeCurrent(targetEntity, LibCharstat.getLife(targetEntity));
    setManaCurrent(targetEntity, LibCharstat.getMana(targetEntity));
  }

  /**
   * @dev Allow target to receive exp, set exp to 0s
   */
  function initExp(bytes32 targetEntity) public context {
    _requireEntityLeaf(uint256(targetEntity));

    uint32[PStat_length] memory exp;
    Experience.set(targetEntity, exp);
  }

  /**
   * @dev Increase target's experience
   * Exp must be initialized
   */
  function increaseExp(bytes32 targetEntity, uint32[PStat_length] memory addExp) public context {
    _requireEntityLeaf(uint256(targetEntity));

    // get current exp, or revert if it doesn't exist
    if (!LibExperience.hasExp(targetEntity)) {
      revert CharstatSystem_ExpNotInitialized();
    }
    uint32[PStat_length] memory exp = Experience.get(targetEntity);

    // increase
    for (uint256 i; i < PStat_length; i++) {
      exp[i] += addExp[i];
    }
    // set increased exp
    Experience.set(targetEntity, exp);
  }
}
