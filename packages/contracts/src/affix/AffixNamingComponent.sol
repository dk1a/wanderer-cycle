// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { StringBareComponent } from "std-contracts/components/StringBareComponent.sol";

uint256 constant ID = uint256(keccak256("component.AffixNaming"));

/**
 * @dev affixNamingEntity = hashed(ID, AffixPartId, targetEntity, affixProtoEntity)
 */
function getAffixNamingEntity(
  AffixPartId partId,
  uint256 targetEntity,
  uint256 affixProtoEntity
) pure returns (uint256) {
  return uint256(keccak256(abi.encode(ID, partId, targetEntity, affixProtoEntity)));
}

enum AffixPartId {
  IMPLICIT,
  PREFIX,
  SUFFIX
}
uint256 constant AFFIX_PARTS_LENGTH = 3;

contract AffixNamingComponent is StringBareComponent {
  constructor(address world) StringBareComponent(world, ID) {}
}