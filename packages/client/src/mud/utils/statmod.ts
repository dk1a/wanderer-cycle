import { Hex, toHex } from "viem";
import { getRecord } from "@latticexyz/stash/internal";
import { ELE_STAT, STATMOD_OP } from "contracts/enums";
import { mudTables, StateLocal } from "../stash";
import { ElementalStatmodTopic, StatmodTopic } from "./topics";
import { formatZeroTerminatedString } from "./format";
import { Elemental } from "./elemental";

export const statmodOpNames = {
  [STATMOD_OP.ADD]: "add",
  [STATMOD_OP.MUL]: "mul",
  [STATMOD_OP.BADD]: "badd",
};

export interface StatmodData {
  entity: Hex;
  statmodTopic: StatmodTopic | ElementalStatmodTopic;
  statmodOp: STATMOD_OP;
  eleStat: ELE_STAT;
  value: number;
}

export function getTopicStatmods(
  state: StateLocal,
  targetEntity: Hex,
  topic: StatmodTopic | ElementalStatmodTopic,
): StatmodData[] {
  const baseEntities =
    getRecord({
      state,
      table: mudTables.statmod__StatmodIdxList,
      key: { targetEntity, statmodTopic: toHex(topic, { size: 32 }) },
    })?.baseEntities ?? [];

  const result: StatmodData[] = [];
  for (const baseEntity of baseEntities) {
    const value =
      getRecord({
        state,
        table: mudTables.statmod__StatmodValue,
        key: { targetEntity, baseEntity },
      })?.value ?? 0;

    const baseStatmod = getRecord({
      state,
      table: mudTables.statmod__StatmodBase,
      key: { entity: baseEntity },
    });

    if (baseStatmod === undefined) {
      console.warn(`No StatmodBase for entity ${baseEntity}`);
      continue;
    }

    result.push({
      entity: baseStatmod.entity,
      statmodTopic: formatZeroTerminatedString(baseStatmod.statmodTopic) as
        | StatmodTopic
        | ElementalStatmodTopic,
      statmodOp: baseStatmod.statmodOp,
      eleStat: baseStatmod.eleStat,
      value,
    });
  }

  return result;
}

export function getValuesFinal(
  state: StateLocal,
  targetEntity: Hex,
  topic: StatmodTopic,
  baseValue: number,
) {
  const statmods = getTopicStatmods(state, targetEntity, topic);
  const resultBadd = baseValue + sumForOp(statmods, STATMOD_OP.BADD);
  const resultMul = Math.floor(
    (resultBadd * (100 + sumForOp(statmods, STATMOD_OP.MUL))) / 100,
  );
  const resultAdd = resultMul + sumForOp(statmods, STATMOD_OP.ADD);
  return resultAdd;
}

export function getValuesElementalFinal(
  state: StateLocal,
  targetEntity: Hex,
  topic: ElementalStatmodTopic,
  baseValues: Elemental,
) {
  const statmods = getTopicStatmods(state, targetEntity, topic);
  const result: Elemental = { ...baseValues };
  for (const eleStat of Object.values(ELE_STAT) as ELE_STAT[]) {
    const resultBadd =
      baseValues[eleStat] +
      sumForElementalOp(statmods, STATMOD_OP.BADD, eleStat);
    const resultMul = Math.floor(
      (resultBadd *
        (100 + sumForElementalOp(statmods, STATMOD_OP.MUL, eleStat))) /
        100,
    );
    const resultAdd =
      resultMul + sumForElementalOp(statmods, STATMOD_OP.ADD, eleStat);
    result[eleStat] = resultAdd;
  }
  return result;
}

/**
 * Sum all statmod values for given operand filter
 */
function sumForOp(statmods: StatmodData[], statmodOpFilter: STATMOD_OP) {
  return statmods
    .filter(({ statmodOp }) => statmodOp === statmodOpFilter)
    .reduce((acc, curr) => acc + curr.value, 0);
}

/**
 * Sum all statmod values for given operand and element filters
 */
function sumForElementalOp(
  statmods: StatmodData[],
  opFilter: STATMOD_OP,
  eleStatFilter: ELE_STAT,
) {
  return statmods
    .filter(
      ({ statmodOp, eleStat }) =>
        statmodOp === opFilter && eleStat === eleStatFilter,
    )
    .reduce((acc, curr) => acc + curr.value, 0);
}
