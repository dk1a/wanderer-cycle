// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.AppliedEffect"));

enum EffectRemovability {
  BUFF,
  DEBUFF,
  PERSISTENT
}

struct EffectStatmod {
  uint256 statmodProtoEntity;
  uint256 value;
}

struct AppliedEffect {
  // effects don't have a prototype component, they come from varied skills, items etc..
  uint256 effectProtoEntity;
  // source helps identify where it came from; TODO but maybe it's not necessary?
  bytes4 source;

  EffectRemovability removability;
  // several effects can have the same statmod,
  // so this list is used when removing an effect to subtract statmod values from the total
  EffectStatmod[] statmods;
}
/*
struct EffectMap {
  // <effectId>TimedBytes32
  TimeManager.TimedBytes32 _duration;
  // <effectId>Bytes32Set
  EnumerableSet.Bytes32Set _effectIds;
  // effectId => EffectData
  mapping(bytes32 => EffectData) _effectData;

  TopicModifierMap.Map _topicModifiers;
}*/

contract AppliedEffectComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](4);
    values = new LibTypes.SchemaValue[](4);

    keys[0] = "effectProtoEntity";
    values[0] = LibTypes.SchemaValue.UINT256;

    keys[1] = "source";
    values[1] = LibTypes.SchemaValue.BYTES4;

    keys[2] = "removability";
    values[2] = LibTypes.SchemaValue.UINT8;

    // TODO what about struct arrays?
    keys[3] = "statmods";
    values[3] = LibTypes.SchemaValue.BYTES_ARRAY;
  }

  function set(uint256 entity, AppliedEffect memory value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (AppliedEffect memory) {
    return abi.decode(getRawValue(entity), (AppliedEffect));
  }
}