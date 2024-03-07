// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { GuiseNameToEntity } from "../codegen/index.sol";

library LibGuise {
  error LibGuise_InvalidGuise();

  function getGuiseEntity(string memory name) internal view returns (bytes32 skillEntity) {
    skillEntity = GuiseNameToEntity.get(keccak256(bytes(name)));
    if (skillEntity == bytes32(0)) {
      revert LibGuise_InvalidGuise();
    }
  }
}
