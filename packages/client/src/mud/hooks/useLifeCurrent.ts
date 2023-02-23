import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";

export const useLifeCurrent = (entity: EntityIndex | undefined) => {
  const {
    components: { LifeCurrent },
  } = useMUD();

  const lifeCurrent = useComponentValue(LifeCurrent, entity);

  return lifeCurrent?.value;
};
