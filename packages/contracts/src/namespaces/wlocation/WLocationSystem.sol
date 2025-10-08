// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ERC165Checker } from "@latticexyz/world/src/ERC165Checker.sol";

import { SmartObjectFramework } from "../evefrontier/SmartObjectFramework.sol";

import { IWLocationSmartObject } from "./IWLocationSmartObject.sol";
import { randomnessSystem } from "../rng/codegen/systems/RandomnessSystemLib.sol";
import { WLocation } from "./codegen/tables/WLocation.sol";
import { WLocationPart } from "./codegen/tables/WLocationPart.sol";
import { WLocationEntrant, WLocationEntrantData } from "./codegen/tables/WLocationEntrant.sol";

contract WLocationSystem is SmartObjectFramework {
  error WLocationSystem_InvalidLocationEntity(bytes32 locationEntity);
  error WLocationSystem_LocationInterfaceNotSupported(bytes32 locationEntity, address locationAddress);
  error WLocationSystem_LocationAlreadyEntered(bytes32 locationEntity, bytes32 entrantEntity);
  error WLocationSystem_LocationNotEntered(bytes32 locationEntity, bytes32 entrantEntity);
  error WLocationSystem_LocationPartAlreadyAccessed(bytes32 locationEntity, bytes32 entrantEntity, bytes32 partEntity);
  error WLocationSystem_LocationPartInvalid(bytes32 locationEntity, bytes32 entrantEntity, bytes32 partEntity);
  error WLocationSystem_RandomnessRequestInvalid(bytes32 locationEntity, bytes32 entrantEntity, bytes32 partEntity);

  function enterLocation(bytes32 locationEntity, bytes32 entrantEntity) public context {
    _requireEntityBranch(locationEntity);
    _requireEntityLeaf(entrantEntity);

    if (WLocationEntrant.getHasEntered(locationEntity, entrantEntity)) {
      revert WLocationSystem_LocationAlreadyEntered(locationEntity, entrantEntity);
    }
    WLocationEntrant.set(
      locationEntity,
      entrantEntity,
      WLocationEntrantData({ hasEntered: true, partEntity: bytes32(0), randomnessRequestId: bytes32(0) })
    );

    _getLocationSmartObject(locationEntity).onEnter(entrantEntity);
  }

  function exitLocation(bytes32 locationEntity, bytes32 entrantEntity) public context {
    _requireEntityBranch(locationEntity);
    _requireEntityLeaf(entrantEntity);

    _requireEnteredLocation(locationEntity, entrantEntity);

    WLocationEntrant.set(
      locationEntity,
      entrantEntity,
      WLocationEntrantData({ hasEntered: false, partEntity: bytes32(0), randomnessRequestId: bytes32(0) })
    );

    _getLocationSmartObject(locationEntity).onExit(entrantEntity);
  }

  function accessPartCommit(bytes32 partEntity, bytes32 entrantEntity) public context {
    bytes32 locationEntity = WLocationPart.get(partEntity);

    _requireEntityBranch(locationEntity);
    _requireEntityBranch(partEntity);
    _requireEntityLeaf(entrantEntity);

    _requireEnteredLocation(locationEntity, entrantEntity);

    if (WLocationEntrant.getPartEntity(locationEntity, entrantEntity) != bytes32(0)) {
      revert WLocationSystem_LocationPartAlreadyAccessed(locationEntity, entrantEntity, partEntity);
    }

    // Set the current location part
    WLocationEntrant.setPartEntity(locationEntity, entrantEntity, partEntity);
    // Request randomness
    bytes32 requestId = randomnessSystem.requestRandomness(partEntity);
    WLocationEntrant.setRandomnessRequestId(locationEntity, entrantEntity, requestId);

    _getLocationSmartObject(locationEntity).onAccessPartCommit(partEntity, entrantEntity);
  }

  function accessPartReveal(bytes32 partEntity, bytes32 entrantEntity) public context {
    bytes32 locationEntity = WLocationPart.get(partEntity);

    _requireEntityBranch(locationEntity);
    _requireEntityBranch(partEntity);
    _requireEntityLeaf(entrantEntity);

    _requireEnteredLocation(locationEntity, entrantEntity);

    if (partEntity == bytes32(0) || partEntity != WLocationEntrant.getPartEntity(locationEntity, entrantEntity)) {
      revert WLocationSystem_LocationPartInvalid(locationEntity, entrantEntity, partEntity);
    }

    bytes32 requestId = WLocationEntrant.getRandomnessRequestId(locationEntity, entrantEntity);
    if (requestId == bytes32(0)) {
      revert WLocationSystem_RandomnessRequestInvalid(locationEntity, entrantEntity, partEntity);
    }

    _getLocationSmartObject(locationEntity).onAccessPartReveal(partEntity, entrantEntity);
  }

  function _requireEnteredLocation(bytes32 locationEntity, bytes32 entrantEntity) internal view {
    if (!WLocationEntrant.getHasEntered(locationEntity, entrantEntity)) {
      revert WLocationSystem_LocationNotEntered(locationEntity, entrantEntity);
    }
  }

  function _getLocationSmartObject(bytes32 locationEntity) internal view returns (IWLocationSmartObject) {
    address locationAddress = WLocation.get(locationEntity);
    if (locationAddress == address(0)) {
      revert WLocationSystem_InvalidLocationEntity(locationEntity);
    }
    if (!ERC165Checker.supportsInterface(locationAddress, type(IWLocationSmartObject).interfaceId)) {
      revert WLocationSystem_LocationInterfaceNotSupported(locationEntity, locationAddress);
    }
    return IWLocationSmartObject(locationAddress);
  }
}
