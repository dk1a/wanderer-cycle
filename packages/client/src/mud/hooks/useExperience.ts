import { Hex } from "viem";
import { mudTables, useStashCustom } from "../stash";
import { getRecord } from "@latticexyz/stash/internal";
import { parseArrayPStat } from "../utils/experience";

export const useExperience = (entity: Hex | undefined) => {
  return useStashCustom((state) => {
    if (entity === undefined) return;
    const result = getRecord({
      state,
      table: mudTables.root__Experience,
      key: {
        entity,
      },
    });
    if (result === undefined) return;
    return parseArrayPStat(result.arrayPStat);
  });
};
