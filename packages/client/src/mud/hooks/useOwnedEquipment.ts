import { getComponentValueStrict, Has, HasValue, Not, ProxyExpand, ProxyRead } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { useEntityQuery } from "../useEntityQuery";
import { equipmentPrototypes } from "../utils/equipment";

export const useOwnedEquipment = () => {
  const {
    world,
    playerEntityId,
    components: { OwnedBy, EquipmentPrototype, FromPrototype },
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
      const protoEntityId = getComponentValueStrict(FromPrototype, entity).value;
      const protoEntity = world.entityToIndex.get(protoEntityId);
      if (!protoEntity) {
        throw new Error("prototype entity index absent for equipment");
      }

      return {
        entity,
        protoEntity,
        protoEntityId,
        protoName: equipmentPrototypes[protoEntityId],
      };
    });
  }, [world, FromPrototype, equipmentEntities]);
};
