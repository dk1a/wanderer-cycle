import { useComponentValue } from "@latticexyz/react";
import { EntityID, EntityIndex } from "@latticexyz/recs";
import { BigNumber } from "ethers";
import { defaultAbiCoder, keccak256 } from "ethers/lib/utils";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { parseScopedDuration } from "../utils/scopedDuration";

export const useDuration = (targetEntity: EntityIndex | undefined, protoEntity: EntityIndex | undefined) => {
  const {
    world,
    components: { DurationScope, DurationValue },
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
  const durationScope = useComponentValue(DurationScope, durationEntity);

  const timeScopeId = useMemo(() => {
    if (!durationScope) return;
    const [, timeScopeId] = defaultAbiCoder.decode(["uint256", "uint256"], durationScope.value);
    return BigNumber.from(timeScopeId).toHexString();
  }, [durationScope]);

  return useMemo(() => {
    if (!durationScope || !timeScopeId || !durationValue) return;
    return {
      durationScopeId: durationScope.value,
      ...parseScopedDuration(timeScopeId, durationValue.value),
    };
  }, [durationScope, timeScopeId, durationValue]);
};
