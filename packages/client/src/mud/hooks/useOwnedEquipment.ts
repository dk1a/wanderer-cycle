import { Has, HasValue, Not, ProxyExpand } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { useEntityQuery } from "../useEntityQuery";
import { getLoot } from "../utils/getLoot";

export const useOwnedEquipment = () => {
  const {
    world,
    playerEntityId,
    components: { OwnedBy, EquipmentPrototype, Loot, FromPrototype, EffectPrototype, AffixNaming },
  } = useMUD();

  const equipmentEntities = useEntityQuery(
    useMemo(
      () => [
        ProxyExpand(FromPrototype, 1),
        Has(EquipmentPrototype),
        ProxyExpand(FromPrototype, 0),
        Not(EquipmentPrototype),
        HasValue(OwnedBy, { value: playerEntityId }),
      ],
      [OwnedBy, EquipmentPrototype, FromPrototype, playerEntityId]
    )
  );

  return useMemo(() => {
    return equipmentEntities.map((entity) => {
      return getLoot(world, { Loot, FromPrototype, EffectPrototype, AffixNaming }, entity);
    });
  }, [world, Loot, FromPrototype, EffectPrototype, AffixNaming, equipmentEntities]);
};
