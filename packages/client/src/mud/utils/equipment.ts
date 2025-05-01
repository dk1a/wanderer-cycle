import { Hex } from "viem";
import { getRecord, getRecords } from "@latticexyz/stash/internal";
import { getRecordStrict, mudTables, StateLocal } from "../stash";
import { getLoot, LootData } from "./getLoot";
import { formatZeroTerminatedString } from "./format";

export interface EquipmentSlot {
  slotEntity: Hex;
  allowedEquipmentTypes: EquipmentType[];
  equippedEntity: Hex | undefined;
  name: string | undefined;
}

export interface EquipmentData extends LootData {
  equipmentType: EquipmentType;
}

export type EquipmentType = (typeof equipmentTypes)[number];

// TODO duplicates solidity code
export const equipmentTypes = [
  "Weapon",
  "Shield",
  "Hat",
  "Clothing",
  "Gloves",
  "Pants",
  "Boots",
  "Amulet",
  "Ring",
] as const;

export function getEquipmentSlots(
  state: StateLocal,
  targetEntity: Hex,
): EquipmentSlot[] {
  const ownedBy = getRecords({
    state,
    table: mudTables.common__OwnedBy,
  });
  const ownedEntities = Object.values(ownedBy)
    .filter(({ toEntity }) => toEntity === targetEntity)
    .map(({ fromEntity }) => fromEntity);

  const allowedSlots = getRecords({
    state,
    table: mudTables.equipment__SlotAllowedType,
  });
  // Don't map this for return value - it's keyed by slotEntity AND equipmentType, and contains duplicate slotEntities
  const ownedAllowedSlots = Object.values(allowedSlots).filter(
    ({ slotEntity, isAllowed }) =>
      isAllowed && ownedEntities.includes(slotEntity),
  );

  const ownedEquipmentSlots: EquipmentSlot[] = [];
  for (const slotEntity of ownedEntities) {
    const allowedEquipmentTypes = ownedAllowedSlots
      .filter((slot) => slot.slotEntity === slotEntity)
      .map(
        ({ equipmentType }) =>
          formatZeroTerminatedString(equipmentType) as EquipmentType,
      );

    if (allowedEquipmentTypes.length > 0) {
      const slotEquipment = getRecord({
        state,
        table: mudTables.equipment__SlotEquipment,
        key: { slotEntity },
      });

      const name = getRecord({
        state,
        table: mudTables.common__Name,
        key: { entity: slotEntity },
      })?.name;

      ownedEquipmentSlots.push({
        slotEntity,
        allowedEquipmentTypes,
        equippedEntity: slotEquipment?.equipmentEntity,
        name,
      });
    }
  }
  return ownedEquipmentSlots;
}

export function getOwnedEquipment(
  state: StateLocal,
  targetEntity: Hex,
): EquipmentData[] {
  const ownedBy = getRecords({
    state,
    table: mudTables.common__OwnedBy,
  });
  const ownedEntities = Object.values(ownedBy)
    .filter(({ toEntity }) => toEntity === targetEntity)
    .map(({ fromEntity }) => fromEntity);

  const equipment = getRecords({
    state,
    table: mudTables.equipment__EquipmentTypeComponent,
  });
  const ownedEquipment = Object.values(equipment).filter(({ entity }) =>
    ownedEntities.includes(entity),
  );

  return ownedEquipment.map(({ entity, value }) => {
    return {
      ...getLoot(state, entity),
      equipmentType: formatZeroTerminatedString(value) as EquipmentType,
    };
  });
}

export function getEquipmentStrict(
  state: StateLocal,
  entity: Hex,
): EquipmentData {
  const equipment = getRecordStrict({
    state,
    table: mudTables.equipment__EquipmentTypeComponent,
    key: { entity },
  });
  return {
    ...getLoot(state, entity),
    equipmentType: formatZeroTerminatedString(equipment.value) as EquipmentType,
  };
}
