import { Hex } from "viem";
import { getRecord } from "@latticexyz/stash/internal";
import { getRecordStrict, mudTables, StateLocal } from "../stash";
import { AffixPrototype, getAffixPrototype } from "./getAffixPrototype";

export enum AffixPartId {
  IMPLICIT,
  PREFIX,
  SUFFIX,
}

export interface LootAffix {
  affixPrototypeEntity: Hex;
  affixPrototype: AffixPrototype;
  partId: AffixPartId;
  value: number;
  naming: string;
}

export function getLootAffixes(
  state: StateLocal,
  affixAvailabilityTargetId: Hex,
  lootEntity: Hex,
) {
  const lootAffixes: LootAffix[] = [];

  const affixEntities = getRecordStrict({
    state,
    table: mudTables.loot__LootAffixes,
    key: { entity: lootEntity },
  }).affixEntities;

  for (const affixEntity of affixEntities) {
    lootAffixes.push(
      getLootAffix(state, affixAvailabilityTargetId, affixEntity),
    );
  }

  return lootAffixes;
}

export function getLootAffix(
  state: StateLocal,
  affixAvailabilityTargetId: Hex,
  affixEntity: Hex,
): LootAffix {
  const affix = getRecordStrict({
    state,
    table: mudTables.affix__Affix,
    key: { entity: affixEntity },
  });

  const affixPrototypeEntity = affix.affixPrototypeEntity;
  const affixPrototype = getAffixPrototype(state, affixPrototypeEntity);

  let namingLabel = getRecord({
    state,
    table: mudTables.affix__AffixNamingTargeted,
    key: {
      affixPrototypeEntity: affixPrototypeEntity,
      affixPart: affix.partId,
      targetId: affixAvailabilityTargetId,
    },
  })?.label;

  if (!namingLabel) {
    namingLabel = getRecord({
      state,
      table: mudTables.affix__AffixNaming,
      key: {
        affixPrototypeEntity: affixPrototypeEntity,
        affixPart: affix.partId,
      },
    })?.label;
  }

  return {
    affixPrototypeEntity,
    affixPrototype,
    partId: affix.partId,
    value: affix.value,
    naming: namingLabel ?? "",
  };
}
