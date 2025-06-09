import { Hex, toHex } from "viem";
import { getRecord } from "@latticexyz/stash/internal";
import { mudTables, StateLocal } from "../stash";
import { EffectTemplateData, getEffectTemplate } from "./getEffect";
import { AffixPartId, getLootAffixes, LootAffix } from "./getLootAffix";

export interface LootData {
  entity: Hex;
  name: string;
  tier: number;
  affixes: LootAffix[];
  effectTemplate: EffectTemplateData;
  affixAvailabilityTargetId: Hex;
}

export function getLoot(state: StateLocal, entity: Hex): LootData {
  const name = getRecord({
    state,
    table: mudTables.common__Name,
    key: { entity },
  })?.name;
  const tier =
    getRecord({ state, table: mudTables.loot__LootTier, key: { entity } })
      ?.value ?? 0;

  const affixAvailabilityTargetId =
    getRecord({ state, table: mudTables.loot__LootTargetId, key: { entity } })
      ?.targetId ?? toHex(0, { size: 32 });

  const affixes = getLootAffixes(state, affixAvailabilityTargetId, entity);

  const effectTemplate = getEffectTemplate(state, entity);
  if (effectTemplate === undefined) {
    throw new Error(`Loot ${entity} has no effect template`);
  }

  return {
    entity,
    name: name ?? getNameFromAffixes(affixes),
    tier,
    affixes,
    effectTemplate,
    affixAvailabilityTargetId,
  };
}

// TODO why not do this onchain?
function getNameFromAffixes(affixes: LootAffix[]) {
  const implicits = affixes.filter(
    ({ partId }) => partId === AffixPartId.IMPLICIT,
  );
  const prefixes = affixes.filter(
    ({ partId }) => partId === AffixPartId.PREFIX,
  );
  const suffixes = affixes.filter(
    ({ partId }) => partId === AffixPartId.SUFFIX,
  );

  const ordered = prefixes.reverse().concat(implicits).concat(suffixes);
  return ordered.map(({ naming }) => naming).join(" ");
}
