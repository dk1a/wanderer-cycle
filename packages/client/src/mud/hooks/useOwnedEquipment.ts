import { useEntityQuery } from "@latticexyz/react";
import { Has, HasValue, Not, ProxyExpand } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { getLoot } from "../utils/getLoot";

export const useOwnedEquipment = () => {
  const { world, playerEntityId, components } = useMUD();
  const { OwnedBy, EquipmentPrototype, FromPrototype } = components;

  const equipmentEntities = useEntityQuery([
    ProxyExpand(FromPrototype, 1),
    Has(EquipmentPrototype),
    ProxyExpand(FromPrototype, 0),
    Not(EquipmentPrototype),
    HasValue(OwnedBy, { value: playerEntityId }),
  ]);

  return useMemo(() => {
    return equipmentEntities.map((entity) => {
      return getLoot(world, components, entity);
    });
  }, [world, components, equipmentEntities]);
};
