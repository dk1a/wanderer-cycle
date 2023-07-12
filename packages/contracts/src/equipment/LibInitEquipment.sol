// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

import { Name, NameTableId, EqptBase } from "../codegen/Tables.sol";

library LibInitEquipment {
  string constant R_HAND = "R Hand";
  string constant L_HAND = "L Hand";
  string constant HEAD = "Head";
  string constant BODY = "Body";
  string constant HANDS = "Hands";
  string constant LEGS = "Legs";
  string constant FEET = "Feet";
  string constant NECK = "Neck";
  string constant R_RING = "R Ring";
  string constant L_RING = "L Ring";

  function spawnBasesEquipment() private {
    _newBaseEquipment(R_HAND);
    _newBaseEquipment(L_HAND);
    _newBaseEquipment(HEAD);
    _newBaseEquipment(BODY);
    _newBaseEquipment(LEGS);
    _newBaseEquipment(FEET);
    _newBaseEquipment(NECK);
    _newBaseEquipment(R_RING);
    _newBaseEquipment(L_RING);
  }

  function _newBaseEquipment(string memory eqptBaseName) private returns (bytes32 eqptBase) {
    bytes32 eqptBase = getUniqueEntity();
    Name.set(eqptBase, eqptBaseName);
    // TODO create new logic for EqptBase.set()
    EqptBase.set(eqptBase, eqptBaseName);

    return eqptBase;
  }
}
