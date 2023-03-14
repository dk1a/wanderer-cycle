import { EntityIndex } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";
import { useComponentValue } from "@latticexyz/react";

export const useActiveWheel = (entity: EntityIndex | undefined) => {
  const {
    components: { ActiveWheel },
  } = useMUD();

  const activeWheel = useComponentValue(ActiveWheel, entity);

  return activeWheel?.value;
};

export const useWheel = (entity: EntityIndex | undefined) => {
  const {
    components: { ActiveWheel },
  } = useMUD();

  const activeWheel = useComponentValue(ActiveWheel, entity);

  return activeWheel?.value;
};
