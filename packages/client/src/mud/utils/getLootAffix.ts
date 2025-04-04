import { Hex } from "viem";
import { TableRecord } from "@latticexyz/store-sync/zustand";
import { StoreState, StoreTables } from "../setup";
import { getValueStrict } from "./getValueStrict";

export enum AffixPartId {
  IMPLICIT,
  PREFIX,
  SUFFIX,
}

export interface LootAffix {
  affixPrototypeEntity: Hex;
  affixPrototype: TableRecord<StoreTables["AffixPrototype"]>["value"];
  partId: AffixPartId;
  value: number;
  naming: string;
}

export function getLootAffixes(
  tables: StoreTables,
  state: StoreState,
  affixAvailabilityTargetId: Hex,
  lootEntity: Hex,
) {
  const lootAffixes: LootAffix[] = [];

  const affixEntities = getValueStrict(state, tables.LootAffixes, {
    entity: lootEntity,
  }).affixEntities;
  for (const affixEntity of affixEntities) {
    lootAffixes.push(
      getLootAffix(tables, state, affixAvailabilityTargetId, affixEntity),
    );
  }

  return lootAffixes;
}

export function getLootAffix(
  tables: StoreTables,
  state: StoreState,
  affixAvailabilityTargetId: Hex,
  affixEntity: Hex,
): LootAffix {
  const affix = getValueStrict(state, tables.Affix, { entity: affixEntity });

  const affixPrototypeEntity = affix.affixPrototypeEntity;
  const affixPrototype = getValueStrict(state, tables.AffixPrototype, {
    entity: affixPrototypeEntity,
  });

  const naming = state.getValue(tables.AffixNaming, {
    affixPart: affix.partId,
    targetId: affixAvailabilityTargetId,
    affixPrototypeEntity: affixPrototypeEntity,
  });

  return {
    affixPrototypeEntity,
    affixPrototype,
    partId: affix.partId,
    value: affix.value,
    naming: naming?.label ?? "",
  };
}
