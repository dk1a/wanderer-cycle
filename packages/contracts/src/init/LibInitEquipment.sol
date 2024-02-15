// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Name, NameTableId, EqptBase } from "../codegen/index.sol";

type Equipment is bytes32;

library LibInitEquipment {
  Equipment constant WEAPON = Equipment.wrap("Weapon");
  Equipment constant SHIELD = Equipment.wrap("Shield");
  Equipment constant HAT = Equipment.wrap("Hat");
  Equipment constant CLOTHING = Equipment.wrap("Clothing");
  Equipment constant GLOVES = Equipment.wrap("Gloves");
  Equipment constant PANTS = Equipment.wrap("Pants");
  Equipment constant BOOTS = Equipment.wrap("Boots");
  Equipment constant AMULET = Equipment.wrap("Amulet");
  Equipment constant RING = Equipment.wrap("Ring");

  function spawnEquipments() external {
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

  function _newBaseEquipment(Equipment eqpt) private {
    string memory name = toString(Equipment.unwrap(eqpt));

    Name.set(Equipment.unwrap(eqpt), name);
    EqptBase.set(Equipment.unwrap(eqpt), true);
  }

  function toString(bytes32 eqpt) public returns (string memory) {
    return string(abi.encodePacked(eqpt));
  }
}
