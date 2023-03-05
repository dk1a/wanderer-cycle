import { useEntityQuery } from "@latticexyz/react";
import { Has, HasValue, Not, ProxyExpand } from "@latticexyz/recs";
import { useMemo } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useMUD } from "../MUDContext";
import { getLoot } from "../utils/getLoot";

export const useOwnedEquipment = () => {
  const { world, components } = useMUD();
  const { cycleEntity } = useWandererContext();
  const { OwnedBy, EquipmentPrototype, FromPrototype } = components;

  const equipmentEntities = useEntityQuery([
    ProxyExpand(FromPrototype, 1),
    Has(EquipmentPrototype),
    ProxyExpand(FromPrototype, 0),
    Not(EquipmentPrototype),
    HasValue(OwnedBy, { value: cycleEntity ? world.entities[cycleEntity] : undefined }),
  ]);

  return useMemo(() => {
    return equipmentEntities.map((entity) => {
      return getLoot(world, components, entity);
    });
  }, [world, components, equipmentEntities]);
};
