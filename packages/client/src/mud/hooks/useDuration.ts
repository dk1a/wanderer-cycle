import { useComponentValue } from "@latticexyz/react";
import { EntityID, EntityIndex } from "@latticexyz/recs";
import { defaultAbiCoder, keccak256, toUtf8Bytes } from "ethers/lib/utils";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";

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
    return timeScopeId as string;
  }, [durationScope]);

  if (!durationScope || !timeScopeId || !durationValue) return;

  return {
    durationScopeId: durationScope.value,
    timeScopeId,
    timeScopeName: timeScopeIdToName[timeScopeId],
    timeValue: durationValue.value,
  };
};

// TODO unhardcode this (start with the contracts side)
const timeScopeIdToName = {
  [keccak256(toUtf8Bytes("turn"))]: "turn",
  [keccak256(toUtf8Bytes("round"))]: "round",
  [keccak256(toUtf8Bytes("round_persistent"))]: "round_persistent",
};
