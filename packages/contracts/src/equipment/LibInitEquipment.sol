// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

import { Name, NameTableId, EqptBase } from "../codegen/Tables.sol";

library LibInitEquipment {
  string constant WEAPON = "WEAPON";
  string constant SHIELD = "SHIELD";
  string constant HAT = "HAT";
  string constant CLOTHING = "CLOTHING";
  string constant GLOVES = "GLOVES";
  string constant PANTS = "PANTS";
  string constant BOOTS = "BOOTS";
  string constant AMULET = "AMULET";
  string constant RING = "RING";

  function spawnBasesEquipment() private {
    _newBaseEquipment(WEAPON);
    _newBaseEquipment(SHIELD);
    _newBaseEquipment(HAT);
    _newBaseEquipment(CLOTHING);
    _newBaseEquipment(GLOVES);
    _newBaseEquipment(PANTS);
    _newBaseEquipment(BOOTS);
    _newBaseEquipment(AMULET);
    _newBaseEquipment(RING);
  }

  function _newBaseEquipment(string memory eqptBaseName) private returns (bytes32 eqptBase) {
    eqptBase = getUniqueEntity();

    Name.set(eqptBase, eqptBaseName);
    EqptBase.set(eqptBase, true);

    return eqptBase;
  }

  function getEqptBaseByName(string memory eqptBaseName) private view returns (bytes32) {
    bytes32[] memory eqptBaseKeys = getKeysWithValue(world, NameTableId, bytes(eqptBaseName));
    if (eqptBaseKeys.length == 0) {
      revert("EqptBase not found");
    }
    return eqptBaseKeys[0];
  }
}
