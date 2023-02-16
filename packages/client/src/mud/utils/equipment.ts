import { EntityID } from "@latticexyz/recs";
import { defaultAbiCoder, keccak256, toUtf8Bytes } from "ethers/lib/utils";

// TODO unhardcode this (start with the contracts side)
export const equipmentPrototypes: Record<EntityID, string> = {
  [getEquipmentProtoEntity("Weapon")]: "Weapon",
  [getEquipmentProtoEntity("Shield")]: "Shield",
  [getEquipmentProtoEntity("Hat")]: "Hat",
  [getEquipmentProtoEntity("Clothing")]: "Clothing",
  [getEquipmentProtoEntity("Gloves")]: "Gloves",
  [getEquipmentProtoEntity("Pants")]: "Pants",
  [getEquipmentProtoEntity("Boots")]: "Boots",
  [getEquipmentProtoEntity("Amulet")]: "Amulet",
  [getEquipmentProtoEntity("Ring")]: "Ring",
};

function getEquipmentProtoEntity(name: string) {
  const componentId = keccak256(toUtf8Bytes("component.EquipmentPrototype"));
  return keccak256(defaultAbiCoder.encode(["uint256", "uint256"], [componentId, name])) as EntityID;
}
