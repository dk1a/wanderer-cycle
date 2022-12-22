// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { System } from "@latticexyz/solecs/src/System.sol";
import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import {
  getAffixProtoEntity,
  AffixPrototype,
  AffixPrototypeComponent,
  ID as AffixPrototypeComponentID
} from "./AffixPrototypeComponent.sol";
import {
  getAffixNamingEntity,
  AffixPartId,
  AffixNamingComponent,
  ID as AffixNamingComponentID
} from "./AffixNamingComponent.sol";
import {
  getAffixAvailabilityEntity,
  AffixAvailabilityComponent,
  ID as AffixAvailabilityComponentID
} from "./AffixAvailabilityComponent.sol";

import { EquipmentPrototypeComponent, ID as EquipmentPrototypeComponentID } from "../equipment/EquipmentPrototypeComponent.sol";

import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";

uint256 constant ID = uint256(keccak256("system.AffixInit"));

uint256 constant MAX_ILVL = 4;

struct AffixPart {
  AffixPartId partId;
  uint256 equipmentProtoEntity;
  string label;
}

contract AffixInitSystem is System {
  error AffixInitSystem__MalformedInput();
  error AffixInitSystem__InvalidEquipmentPrototype();

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function executeTyped(
    string memory affixName,
    AffixPrototype memory proto,
    AffixPart[] memory affixParts
  ) public {
    execute(abi.encode(affixName, proto, affixParts));
  }

  function execute(bytes memory args) public override onlyOwner returns (bytes memory) {
    (
      string memory affixName,
      AffixPrototype memory proto,
      AffixPart[] memory affixParts
    ) = abi.decode(args, (string, AffixPrototype, AffixPart[]));

    if (proto.requiredIlvl > MAX_ILVL) {
      revert AffixInitSystem__MalformedInput();
    }

    // check that equipmentProtoEntity exists
    EquipmentPrototypeComponent equipmentProtoComp
      = EquipmentPrototypeComponent(getAddressById(components, EquipmentPrototypeComponentID));
    if (!equipmentProtoComp.has(proto.statmodProtoEntity)) {
      revert AffixInitSystem__InvalidEquipmentPrototype();
    }

    AffixPrototypeComponent protoComp
      = AffixPrototypeComponent(getAddressById(components, AffixPrototypeComponentID));
    AffixNamingComponent namingComp
      = AffixNamingComponent(getAddressById(components, AffixNamingComponentID));
    AffixAvailabilityComponent availabilityComp
      = AffixAvailabilityComponent(getAddressById(components, AffixAvailabilityComponentID));

    NameComponent nameComp = NameComponent(getAddressById(components, NameComponentID));

    uint256 protoEntity = getAffixProtoEntity(affixName, proto.tier);
    nameComp.set(protoEntity, affixName);
    protoComp.set(protoEntity, proto);

    for (uint256 i; i < affixParts.length; i++) {
      AffixPartId partId = affixParts[i].partId;
      uint256 equipmentProtoEntity = affixParts[i].equipmentProtoEntity;
      string memory label = affixParts[i].label;

      // which (partId+equipmentProto) the affix is available for.
      // affixProto => equipmentProto => AffixPartId => label
      uint256 namingEntity = getAffixNamingEntity(partId, equipmentProtoEntity, protoEntity);
      namingComp.set(namingEntity, label);

      // availability component is basically a cache for given parameters,
      // all its data is technically redundant, but greatly simplifies and speeds up queries.
      // equipmentProto => partId => range(requiredIlvl, MAX_ILVL) => Set(affixProtos)
      for (uint256 ilvl = proto.requiredIlvl; ilvl < MAX_ILVL; ilvl++) {
        uint256 availabilityEntity = getAffixAvailabilityEntity(ilvl, partId, equipmentProtoEntity);
        availabilityComp.addItem(availabilityEntity, protoEntity);
      }
    }

    return '';
  }
}