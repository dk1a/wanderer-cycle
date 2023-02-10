import { useComponentValue } from "@latticexyz/react";
import { EntityID, EntityIndex } from "@latticexyz/recs";
import { defaultAbiCoder, keccak256 } from "ethers/lib/utils";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";

export const useDurationValue = (targetEntity: EntityIndex | undefined, protoEntity: EntityIndex | undefined) => {
  const {
    world,
    components: { DurationValue },
  } = useMUD();

  const durationEntity = useMemo(() => {
    if (!targetEntity || !protoEntity) return;
    const bytes = defaultAbiCoder.encode(
      ["uint256", "uint256"],
      [world.entities[targetEntity], world.entities[protoEntity]]
    );
    const entityId = keccak256(bytes) as EntityID;
    return world.entityToIndex.get(entityId);
  }, [world, targetEntity, protoEntity]);

  const durationValue = useComponentValue(DurationValue, durationEntity);
  return durationValue?.value;
};
