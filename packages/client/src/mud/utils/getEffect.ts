import { Hex } from "viem";
import { StoreState, StoreTables } from "../setup";
import { getValueStrict } from "./getValueStrict";

export interface EffectStatmod {
  statmodEntity: Hex;
  value: number;
}

export interface EffectTemplate {
  entity: Hex;
  statmods: EffectStatmod[];
}

export interface EffectApplied {
  targetEntity: Hex;
  applicationEntity: Hex;
  statmods: EffectStatmod[];
  effectSource: EffectSource;
}

export enum EffectSource {
  UNKNOWN,
  SKILL,
  EQUIPMENT,
  MAP,
}

export function getEffectTemplate(
  tables: StoreTables,
  state: StoreState,
  entity: Hex,
) {
  const effect = getValueStrict(state, tables.EffectTemplate, { entity });
  const statmods = parseEffectStatmods(effect.statmodEntities, effect.values);

  return {
    entity,
    statmods,
  };
}

export function getEffectApplied(
  tables: StoreTables,
  state: StoreState,
  targetEntity: Hex,
  applicationEntity: Hex,
) {
  const effect = getValueStrict(state, tables.EffectApplied, {
    targetEntity,
    applicationEntity,
  });
  const statmods = parseEffectStatmods(effect.statmodEntities, effect.values);

  const effectSource = getEffectSource(tables, state, applicationEntity);

  return {
    targetEntity,
    applicationEntity,
    statmods,
    effectSource,
  };
}

function parseEffectStatmods(
  statmodEntities: readonly Hex[],
  values: readonly number[],
): EffectStatmod[] {
  if (statmodEntities.length !== values.length) {
    throw new Error(
      `Length mismatch for statmodEntities and values: ${statmodEntities.length} ${values.length}`,
    );
  }

  const effectStatmods: EffectStatmod[] = [];
  for (let i = 0; i < statmodEntities.length; i++) {
    effectStatmods.push({
      statmodEntity: statmodEntities[i],
      value: values[i],
    });
  }
  return effectStatmods;
}

function getEffectSource(tables: StoreTables, state: StoreState, entity: Hex) {
  if (state.getValue(tables.SkillTemplate, { entity })) {
    return EffectSource.SKILL;
  } else if (state.getValue(tables.EquipmentTypeComponent, { entity })) {
    return EffectSource.EQUIPMENT;
  } else if (state.getValue(tables.MapTypeComponent, { entity })) {
    return EffectSource.MAP;
  } else {
    return EffectSource.UNKNOWN;
  }
}
