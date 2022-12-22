// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "@latticexyz/solecs/src/LibTypes.sol";
import { BareComponent } from "@latticexyz/solecs/src/BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.StatmodPrototype"));

/**
 * @dev Statmod protoEntity = hashed(ID, StatmodPrototype)
 */
function getStatmodProtoEntity(StatmodPrototype memory proto) pure returns (uint256) {
  return uint256(keccak256(abi.encode(ID, proto)));
}

enum Op {
  ADD,
  MUL,
  BADD
}
uint256 constant OP_L = 3;
uint256 constant OP_FINAL = uint256(Op.ADD);

enum Element {
  ALL,
  PHYSICAL,
  FIRE,
  COLD,
  POISON
}
uint256 constant EL_L = 5;

struct StatmodPrototype {
  uint256 topicEntity;
  Op op;
  Element element;
}

contract StatmodPrototypeComponent is BareComponent {
  error StatmodPrototypeComponent__AbsentEntity();

  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](3);
    values = new LibTypes.SchemaValue[](3);

    keys[0] = "topicEntity";
    values[0] = LibTypes.SchemaValue.UINT256;

    keys[1] = "op";
    values[1] = LibTypes.SchemaValue.UINT8;

    keys[2] = "element";
    values[2] = LibTypes.SchemaValue.UINT8;
  }

  function set(uint256 entity, StatmodPrototype memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (StatmodPrototype memory) {
    bytes memory rawValue = getRawValue(entity);
    if (rawValue.length == 0) {
      revert StatmodPrototypeComponent__AbsentEntity();
    }
    return abi.decode(rawValue, (StatmodPrototype));
  }
}

