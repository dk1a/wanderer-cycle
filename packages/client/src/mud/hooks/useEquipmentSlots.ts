import { EntityIndex, getComponentValueStrict, Has, HasValue } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { useEntityQuery } from "../useEntityQuery";

export const useEquipmentSlots = (ownerEntity: EntityIndex | undefined) => {
  const {
    world,
    components: { OwnedBy, Name, EquipmentSlotAllowed },
  } = useMUD();
  // TODO it may be better to restructure stuff so ownerEntity can't be undefined
  const ownerEntityId = ownerEntity ? world.entities[ownerEntity] : undefined;

  const equipmentSlotEntities = useEntityQuery(
    useMemo(
      () => [HasValue(OwnedBy, { value: ownerEntityId }), Has(EquipmentSlotAllowed)],
      [OwnedBy, EquipmentSlotAllowed, ownerEntityId]
    )
  );

  return useMemo(() => {
    return equipmentSlotEntities.map((entity) => {
      const name = getComponentValueStrict(Name, entity).value;
      const equipmentProtoEntityIds = getComponentValueStrict(EquipmentSlotAllowed, entity).value;
      return {
        entity,
        name,
        equipmentProtoEntityIds,
      };
    });
  }, [Name, EquipmentSlotAllowed, equipmentSlotEntities]);
};
