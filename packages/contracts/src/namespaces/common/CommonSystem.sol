// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SmartObjectFramework } from "../evefrontier/SmartObjectFramework.sol";

import { Name } from "./codegen/tables/Name.sol";
import { OwnedBy } from "./codegen/tables/OwnedBy.sol";

contract CommonSystem is SmartObjectFramework {
  function setName(bytes32 entity, string memory name) public context {
    _requireEntityLeaf(entity);

    Name.set(entity, name);
  }

  function setOwnedBy(bytes32 entity, bytes32 ownerEntity) public context {
    _requireEntityLeaf(entity);

    OwnedBy.set(entity, ownerEntity);
  }
}
