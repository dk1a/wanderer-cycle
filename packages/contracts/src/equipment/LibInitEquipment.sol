// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

import { Name, NameTableId, EqptBase } from "../codegen/Tables.sol";

library LibInitEquipment {
  function _newBaseEquipment(string memory base) private returns (bytes32 eqptBase) {
    bytes32 eqptBase = getUniqueEntity();
    Name.set(eqptBase, base);
    EqptBase.set(eqptBase, base);
    return eqptBase;
  }

  function spawnBasesEquipment() internal {
    bytes32 WEAPON = _newBaseEquipment("WEAPON");
    bytes32 SHIELD = _newBaseEquipment("SHIELD");
    bytes32 HAT = _newBaseEquipment("HAT");
    bytes32 CLOTHING = _newBaseEquipment("CLOTHING");
    bytes32 GLOVES = _newBaseEquipment("GLOVES");
    bytes32 PANTS = _newBaseEquipment("PANTS");
    bytes32 BOOTS = _newBaseEquipment("BOOTS");
    bytes32 AMULET = _newBaseEquipment("AMULET");
    bytes32 RING = _newBaseEquipment("RING");
  }
}
