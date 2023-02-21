import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { getStatmodPrototype } from "../utils/getStatmodPrototype";

export const useStatmodPrototype = (entity: EntityIndex) => {
  const {
    world,
    components: { StatmodPrototype, Name, ReverseHashName },
  } = useMUD();

  return useMemo(
    () => getStatmodPrototype(world, { StatmodPrototype, Name, ReverseHashName }, entity),
    [world, StatmodPrototype, Name, ReverseHashName, entity]
  );
};
