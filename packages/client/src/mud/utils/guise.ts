import { Hex } from "viem";
import { getRecord, getRecords } from "@latticexyz/stash/internal";
import { getRecordStrict, mudTables, StateLocal } from "../stash";
import { parseArrayPStat } from "./experience";

export type GuiseData = ReturnType<typeof getGuise>;

export function getGuise(state: StateLocal, entity: Hex) {
  const guisePrototype = getRecordStrict({
    state,
    table: mudTables.root__GuisePrototype,
    key: {
      entity,
    },
  });
  const skillEntities = getRecord({
    state,
    table: mudTables.root__GuiseSkills,
    key: {
      entity,
    },
  });

  const name = getRecordStrict({
    state,
    table: mudTables.root__GuiseName,
    key: {
      entity,
    },
  });

  return {
    entity,
    name: name?.name ?? "",

    levelMul: parseArrayPStat(guisePrototype.arrayPStat),

    skillEntities: Object.values(skillEntities?.entityArray ?? []),
  };
}

export function getGuises(state: StateLocal) {
  const guises = getRecords({
    state,
    table: mudTables.root__GuisePrototype,
  });
  return Object.values(guises).map(({ entity }) => getGuise(state, entity));
}

export function getActiveGuise(
  state: StateLocal,
  targetEntity: Hex | undefined,
) {
  if (targetEntity === undefined) return undefined;

  const activeGuise = getRecord({
    state,
    table: mudTables.root__ActiveGuise,
    key: {
      fromEntity: targetEntity,
    },
  });

  if (!activeGuise) {
    return undefined;
  } else {
    return getGuise(state, activeGuise.toEntity);
  }
}
