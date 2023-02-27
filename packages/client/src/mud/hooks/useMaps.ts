import { useEntityQuery } from "@latticexyz/react";
import { Has, HasValue, Not, ProxyExpand, ProxyRead } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";

export const useMaps = (prototypeName: string) => {
  const {
    components: { MapPrototype, Name, FromPrototype },
  } = useMUD();

  return useEntityQuery(
    useMemo(
      () => [
        ProxyRead(FromPrototype, 1),
        ProxyExpand(FromPrototype, 1),
        Has(MapPrototype),
        HasValue(Name, { value: prototypeName }),
        ProxyRead(FromPrototype, 0),
        ProxyExpand(FromPrototype, 0),
        Not(MapPrototype),
      ],
      [FromPrototype, MapPrototype, Name, prototypeName]
    )
  );
};
