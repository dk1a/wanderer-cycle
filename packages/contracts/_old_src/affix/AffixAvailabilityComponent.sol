// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Uint256SetComponent } from "../Uint256SetComponent.sol";

import { AffixPartId } from "./AffixNamingComponent.sol";

uint256 constant ID = uint256(keccak256("component.AffixAvailability"));

/**
 * @dev affixAvailabilityEntity = hashed(ID, ilvl, AffixPartId, targetEntity)
 */
function getAffixAvailabilityEntity(uint256 ilvl, AffixPartId partId, uint256 targetEntity) pure returns (uint256) {
  return uint256(keccak256(abi.encode(ID, ilvl, partId, targetEntity)));
}

contract AffixAvailabilityComponent is Uint256SetComponent {
  constructor(address world) Uint256SetComponent(world, ID) {}
}
