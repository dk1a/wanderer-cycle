import { useEntityQuery } from "@latticexyz/react";
import { Has, HasValue, Not, ProxyExpand, ProxyRead } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { getLoot } from "../utils/getLoot";

export const useMaps = (prototypeName: string) => {
  const { world, components } = useMUD();
  const { MapPrototype, Name, FromPrototype } = components;

  const mapEntities = useEntityQuery([
    ProxyRead(FromPrototype, 1),
    ProxyExpand(FromPrototype, 1),
    Has(MapPrototype),
    HasValue(Name, { value: prototypeName }),
    ProxyRead(FromPrototype, 0),
    ProxyExpand(FromPrototype, 0),
    Not(MapPrototype),
  ]);

  return useMemo(() => {
    return mapEntities
      .map((mapEntity) => {
        return getLoot(world, components, mapEntity);
      })
      .sort((a, b) => a.ilvl - b.ilvl);
  }, [world, components, mapEntities]);
};
