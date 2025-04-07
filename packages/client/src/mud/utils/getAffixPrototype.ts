import { Hex } from "viem";
import { getRecords, TableRecord } from "@latticexyz/stash/internal";
import { getRecordStrict, mudTables, StateLocal } from "../stash";

export type AffixPrototype = TableRecord<
  (typeof mudTables)["affix__AffixPrototype"]
>;

export function getAffixPrototype(
  state: StateLocal,
  affixPrototypeEntity: Hex,
): AffixPrototype {
  return getRecordStrict({
    state,
    table: mudTables.affix__AffixPrototype,
    key: { entity: affixPrototypeEntity },
  });
}

export function getAffixPrototypes(
  state: StateLocal,
  affixPrototypeEntities: Hex[],
): AffixPrototype[] {
  const result = getRecords({
    state,
    table: mudTables.affix__AffixPrototype,
  });
  return Object.values(result).filter(({ entity }) =>
    affixPrototypeEntities.includes(entity),
  );
}
