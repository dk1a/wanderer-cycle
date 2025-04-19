import { Hex } from "viem";
import { getRecord } from "@latticexyz/stash/internal";
import { getRecordStrict, mudTables, StateLocal } from "../stash";

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

export function getEffectTemplate(state: StateLocal, entity: Hex) {
  const effect = getRecordStrict({
    state,
    table: mudTables.effect__EffectTemplate,
    key: { entity },
  });
  const statmods = parseEffectStatmods(effect.statmodEntities, effect.values);

  return {
    entity,
    statmods,
  };
}

export function getEffectApplied(
  state: StateLocal,
  targetEntity: Hex,
  applicationEntity: Hex,
) {
  const effect = getRecordStrict({
    state,
    table: mudTables.effect__EffectApplied,
    key: { targetEntity, applicationEntity },
  });
  const statmods = parseEffectStatmods(effect.statmodEntities, effect.values);

  const effectSource = getEffectSource(state, applicationEntity);

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

function getEffectSource(state: StateLocal, entity: Hex) {
  if (
    getRecord({ state, table: mudTables.skill__SkillTemplate, key: { entity } })
  ) {
    return EffectSource.SKILL;
  } else if (
    getRecord({
      state,
      table: mudTables.equipment__EquipmentTypeComponent,
      key: { entity },
    })
  ) {
    return EffectSource.EQUIPMENT;
  } else if (
    getRecord({
      state,
      table: mudTables.map__MapTypeComponent,
      key: { entity },
    })
  ) {
    return EffectSource.MAP;
  } else {
    return EffectSource.UNKNOWN;
  }
}
