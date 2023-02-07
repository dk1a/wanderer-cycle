import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";

export const useManaCurrent = (entity: EntityIndex) => {
  const {
    components: { ManaCurrent },
  } = useMUD();

  const manaCurrent = useComponentValue(ManaCurrent, entity);

  return manaCurrent?.value;
};
