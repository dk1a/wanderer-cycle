// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

//import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
//import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";
//import { Name, NameTableId, EqptBase } from "../codegen/index.sol";
//
//library LibInitEquipment {
//  mapping(string => bytes32) private equipmentIds;
//
//  function init() external {
//    string[9] memory equipmentTypes = [
//          "WEAPON",
//          "SHIELD",
//          "HAT",
//          "CLOTHING",
//          "GLOVES",
//          "PANTS",
//          "BOOTS",
//          "AMULET",
//          "RING"
//      ];
//
//    for (uint i = 0; i < equipmentTypes.length; i++) {
//      bytes32 eqptId = _newBaseEquipment(equipmentTypes[i]);
//      equipmentIds[equipmentTypes[i]] = eqptId;
//    }
//  }
//
//  function _newBaseEquipment(string memory eqptBaseName) private returns (bytes32 eqptBase) {
//    eqptBase = getUniqueEntity();
//
//    Name.set(eqptBase, eqptBaseName);
//    EqptBase.set(eqptBase, true);
//
//    return eqptBase;
//  }
//
//  function getEquipmentId(string memory name) external view returns (bytes32) {
//    require(equipmentIds[name] != bytes32(0), "Equipment not found");
//    return equipmentIds[name];
//  }
//}
