import { getComponentValueStrict, Has, HasValue } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { useEntityQuery } from "../useEntityQuery";
import { equipmentPrototypes } from "../utils/equipment";

export const useOwnedEquipment = () => {
  const {
    world,
    playerEntityId,
    components: { WNFT_Ownership, EquipmentPrototype, FromPrototype },
  } = useMUD();

  const equipmentEntities = useEntityQuery(
    useMemo(
      () => [HasValue(WNFT_Ownership, { value: playerEntityId }), Has(EquipmentPrototype)],
      [WNFT_Ownership, EquipmentPrototype, playerEntityId]
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
