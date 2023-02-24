import { EntityIndex, getComponentValue, hasComponent, World } from "@latticexyz/recs";
import { defineEffectComponent } from "../components/EffectComponent";
import { SetupResult } from "../setup";
import { parseEffectStatmods } from "./effectStatmod";

export enum EffectRemovability {
  BUFF,
  DEBUFF,
  PERSISTENT,
}

export enum EffectSource {
  SKILL,
  NFT,
  OWNABLE,
}

export type EffectPrototype = ReturnType<typeof getEffectPrototype>;
export type AppliedEffect = ReturnType<typeof getAppliedEffect>;

export function getEffectPrototype(
  world: World,
  component: ReturnType<typeof defineEffectComponent>,
  entity: EntityIndex
) {
  const effectPrototype = getComponentValue(component, entity);
  if (!effectPrototype) return;
  const statmods = parseEffectStatmods(world, effectPrototype.statmodProtoEntities, effectPrototype.statmodValues);

  return {
    entity,
    removability: effectPrototype.removability as EffectRemovability,
    statmods,
  };
}

type GetAppliedEffectComponents = Pick<
  SetupResult["components"],
  "AppliedEffect" | "SkillPrototype" | "WNFT_Ownership" | "OwnedBy"
>;

export function getAppliedEffect(
  world: World,
  components: GetAppliedEffectComponents,
  appliedEntity: EntityIndex,
  protoEntity: EntityIndex
) {
  const { AppliedEffect, SkillPrototype, WNFT_Ownership, OwnedBy } = components;

  const effectPrototypeData = getEffectPrototype(world, AppliedEffect, appliedEntity);

  const effectSource = (() => {
    if (hasComponent(SkillPrototype, protoEntity)) {
      return EffectSource.SKILL;
    } else if (hasComponent(WNFT_Ownership, protoEntity)) {
      return EffectSource.NFT;
    } else if (hasComponent(OwnedBy, protoEntity)) {
      return EffectSource.OWNABLE;
    } else {
      throw new Error(`Unable to determine effect source for ${world.entities[protoEntity]}`);
    }
  })();

  return {
    ...effectPrototypeData,
    protoEntity,
    effectSource,
  };
}
