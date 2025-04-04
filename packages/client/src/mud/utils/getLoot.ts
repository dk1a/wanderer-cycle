import { Hex, toHex } from "viem";
import { StoreState, StoreTables } from "../setup";
import { EffectTemplate, getEffectTemplate } from "./getEffect";
import { AffixPartId, getLootAffixes, LootAffix } from "./getLootAffix";

export interface LootData {
  entity: Hex;
  name: string;
  ilvl: number;
  affixes: LootAffix[];
  effectTemplate: EffectTemplate;
  affixAvailabilityTargetId: Hex;
}

export function getLoot(
  tables: StoreTables,
  state: StoreState,
  entity: Hex,
): LootData {
  const name = state.getValue(tables.Name, { entity })?.name;
  const ilvl = state.getValue(tables.LootIlvl, { entity })?.value ?? 0;

  const affixAvailabilityTargetId =
    state.getValue(tables.LootTargetId, { entity })?.targetId ?? toHex(0);

  const affixes = getLootAffixes(
    tables,
    state,
    affixAvailabilityTargetId,
    entity,
  );

  const effectTemplate = getEffectTemplate(tables, state, entity);

  return {
    entity,
    name: name ?? getNameFromAffixes(affixes),
    ilvl,
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
