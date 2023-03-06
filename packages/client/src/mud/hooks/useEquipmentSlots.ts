import { EntityIndex, getComponentValueStrict, Has, HasValue } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { useEntityQuery } from "../useEntityQuery";
import { getLoot } from "../utils/getLoot";
import { EquipmentAction, useChangeCycleEquipment } from "./useChangeCycleEquipment";

export type EquipmentSlot = ReturnType<typeof useEquipmentSlots>[number];

export const useEquipmentSlots = (ownerEntity: EntityIndex | undefined) => {
  const { world, components } = useMUD();
  const { OwnedBy, EquipmentSlotAllowed, EquipmentSlot } = components;

  const changeCycleEquipment = useChangeCycleEquipment();
  // TODO it may be better to restructure stuff so ownerEntity can't be undefined
  const ownerEntityId = ownerEntity ? world.entities[ownerEntity] : undefined;

  const slotEntities = useEntityQuery([HasValue(OwnedBy, { value: ownerEntityId }), Has(EquipmentSlotAllowed)], true);

  // TODO this is very hacky reactivity nonsense, refactor in v2
  const slotEntitiesWithEquipment = useEntityQuery(
    [HasValue(OwnedBy, { value: ownerEntityId }), Has(EquipmentSlot)],
    true
  );

  return useMemo(() => {
    return slotEntities.map((slotEntity) => {
      const { Name, EquipmentSlotAllowed, EquipmentSlot } = components;

      const name = getComponentValueStrict(Name, slotEntity).value;
      const equipmentProtoEntityIds = getComponentValueStrict(EquipmentSlotAllowed, slotEntity).value;

      const equippedEntity = (() => {
        if (!slotEntitiesWithEquipment.includes(slotEntity)) return;

        const equippedEntityId = getComponentValueStrict(EquipmentSlot, slotEntity).value;
        const equippedEntity = world.entityToIndex.get(equippedEntityId);
        if (!equippedEntity) {
          throw new Error(`No entity index for equipped entity id ${equippedEntityId}`);
        }
        return equippedEntity;
      })();

      const unequip = () => {
        if (equippedEntity === undefined) throw new Error("Slot has not equipment to unequip");
        changeCycleEquipment(EquipmentAction.UNEQUIP, slotEntity, equippedEntity);
      };

      return {
        entity: slotEntity,
        name,
        equipmentProtoEntityIds,
        equipped: equippedEntity ? getLoot(world, components, equippedEntity) : undefined,
        unequip,
      };
    });
  }, [world, components, slotEntities, slotEntitiesWithEquipment, changeCycleEquipment]);
};
