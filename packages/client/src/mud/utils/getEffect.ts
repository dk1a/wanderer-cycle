import {
  Entity,
  getComponentValue,
  getComponentValueStrict,
  hasComponent,
  World,
} from "@latticexyz/recs";
import { defineEffectComponent } from "../components/EffectComponent";
import { SetupResult } from "../setup";
import { parseEffectStatmods } from "./effectStatmod";

export enum EffectRemovability {
  BUFF,
  DEBUFF,
  PERSISTENT,
}

export enum EffectSource {
  UNKNOWN,
  SKILL,
  NFT,
  OWNABLE,
  MAP,
}

export type EffectPrototype = ReturnType<typeof getEffectPrototype>;
export type AppliedEffect = ReturnType<typeof getAppliedEffect>;

export function getEffectPrototype(
  world: World,
  component: ReturnType<typeof defineEffectComponent>,
  entity: Entity,
) {
  const effectPrototype = getComponentValue(component, entity);
  if (!effectPrototype) return;
  const statmods = parseEffectStatmods(
    world,
    effectPrototype.statmodProtoEntities,
    effectPrototype.statmodValues,
  );

  return {
    entity,
    removability: effectPrototype.removability as EffectRemovability,
    statmods,
  };
}

type GetAppliedEffectComponents = Pick<
  SetupResult["components"],
  | "AppliedEffect"
  | "SkillPrototype"
  | "WNFT_Ownership"
  | "OwnedBy"
  | "FromPrototype"
  | "MapPrototype"
>;

export function getAppliedEffect(
  world: World,
  components: GetAppliedEffectComponents,
  appliedEntity: Entity,
  protoEntity: Entity,
) {
  const {
    AppliedEffect,
    SkillPrototype,
    WNFT_Ownership,
    OwnedBy,
    FromPrototype,
    MapPrototype,
  } = components;

  const effectPrototypeData = getEffectPrototype(
    world,
    AppliedEffect,
    appliedEntity,
  );

  const effectSource = (() => {
    if (hasComponent(SkillPrototype, protoEntity)) {
      return EffectSource.SKILL;
    } else if (hasComponent(WNFT_Ownership, protoEntity)) {
      return EffectSource.NFT;
    } else if (hasComponent(OwnedBy, protoEntity)) {
      return EffectSource.OWNABLE;
    } else if (hasComponent(FromPrototype, protoEntity)) {
      // the `protoEntity` in this context is what spawned the effect, and it can have its own prototype
      const protoProtoEntityId = getComponentValueStrict(
        FromPrototype,
        protoEntity,
      ).value;
      const protoProtoEntity = world.entityToIndex.get(protoProtoEntityId);
      if (protoProtoEntity === undefined) return EffectSource.UNKNOWN;

      if (hasComponent(MapPrototype, protoProtoEntity)) {
        return EffectSource.MAP;
      } else {
        return EffectSource.UNKNOWN;
      }
    } else {
      return EffectSource.UNKNOWN;
    }
  })();

  return {
    ...effectPrototypeData,
    protoEntity,
    effectSource,
  };
}
