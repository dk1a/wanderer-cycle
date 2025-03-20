// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { UniqueIdx_GuiseName_Name } from "../codegen/idxs/UniqueIdx_GuiseName_Name.sol";

library LibGuise {
  error LibGuise_NameNotFound(string name);

  function getGuiseEntity(string memory name) internal view returns (bytes32 guiseEntity) {
    guiseEntity = UniqueIdx_GuiseName_Name.get(name);
    if (guiseEntity == bytes32(0)) {
      revert LibGuise_NameNotFound(name);
    }
  }
}
