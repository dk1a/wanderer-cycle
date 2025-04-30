import { Hex } from "viem";
import { getRecord, getRecords } from "@latticexyz/stash/internal";
import { getRecordStrict, mudTables, StateLocal } from "../stash";
import { getDurationRecord, ParsedDuration } from "./duration";

export interface EffectStatmodData {
  statmodEntity: Hex;
  value: number;
}

export interface EffectTemplateData {
  entity: Hex;
  statmods: EffectStatmodData[];
}

export interface EffectAppliedData {
  targetEntity: Hex;
  applicationEntity: Hex;
  statmods: EffectStatmodData[];
  effectSource: EffectSource;
  duration: ParsedDuration | undefined;
}

export enum EffectSource {
  UNKNOWN,
  SKILL,
  EQUIPMENT,
  MAP,
}

export function getEffectTemplate(
  state: StateLocal,
  entity: Hex,
): EffectTemplateData | undefined {
  const effect = getRecord({
    state,
    table: mudTables.effect__EffectTemplate,
    key: { entity },
  });
  if (effect === undefined) return;
  const statmods = parseEffectStatmods(effect.statmodEntities, effect.values);

  return {
    entity,
    statmods,
  };
}

export function getEffectsApplied(
  state: StateLocal,
  targetEntity: Hex,
): EffectAppliedData[] {
  const effects = getRecords({
    state,
    table: mudTables.effect__EffectApplied,
  });
  return Object.values(effects)
    .filter((effect) => effect.targetEntity === targetEntity)
    .map((effect) =>
      getEffectApplied(state, targetEntity, effect.applicationEntity),
    );
}

export function getEffectApplied(
  state: StateLocal,
  targetEntity: Hex,
  applicationEntity: Hex,
): EffectAppliedData {
  const effect = getRecordStrict({
    state,
    table: mudTables.effect__EffectApplied,
    key: { targetEntity, applicationEntity },
  });
  const statmods = parseEffectStatmods(effect.statmodEntities, effect.values);

  const effectSource = getEffectSource(state, applicationEntity);

  const duration = getDurationRecord({
    state,
    table: mudTables.effect__EffectDuration,
    key: { targetEntity, applicationEntity },
  });

  return {
    targetEntity,
    applicationEntity,
    statmods,
    effectSource,
    duration,
  };
}

function parseEffectStatmods(
  statmodEntities: readonly Hex[],
  values: readonly number[],
): EffectStatmodData[] {
  if (statmodEntities.length !== values.length) {
    throw new Error(
      `Length mismatch for statmodEntities and values: ${statmodEntities.length} ${values.length}`,
    );
  }

  const effectStatmods: EffectStatmodData[] = [];
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
