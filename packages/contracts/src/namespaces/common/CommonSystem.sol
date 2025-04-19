// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { Name } from "./codegen/tables/Name.sol";
import { OwnedBy } from "./codegen/tables/OwnedBy.sol";

// TODO add access control!
contract CommonSystem is System {
  function setName(bytes32 entity, string memory name) public {
    Name.set(entity, name);
  }

  function setOwnedBy(bytes32 entity, bytes32 ownerEntity) public {
    OwnedBy.set(entity, ownerEntity);
  }
}
