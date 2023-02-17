import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";
import { parseLootAffixes } from "../utils/lootAffix";
import { useEffectPrototype } from "./useEffectPrototype";

export const useLoot = (entity: EntityIndex) => {
  const {
    world,
    components: { Loot, Name },
  } = useMUD();

  const loot = useComponentValue(Loot, entity);
  const effect = useEffectPrototype(entity);
  const name = useComponentValue(Name, entity)?.value;

  if (!loot || !effect) return;

  return {
    name,
    ilvl: loot.ilvl,
    affixes: parseLootAffixes(world, loot.affixPartIds, loot.affixProtoEntities, loot.affixValues),
    effect,
  };
};
