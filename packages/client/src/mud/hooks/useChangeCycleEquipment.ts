import { EntityIndex } from "@latticexyz/recs";
import { useCallback } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useMUD } from "../MUDContext";
import { toastPromise } from "../utils/toast";
import { getLoot } from "../utils/getLoot";

export enum EquipmentAction {
  UNEQUIP,
  EQUIP,
}

export const useChangeCycleEquipment = () => {
  const { world, systems, components } = useMUD();
  const { selectedWandererEntity } = useWandererContext();

  return useCallback(
    async (action: EquipmentAction, equipmentSlot: EntityIndex, equipmentEntity: EntityIndex) => {
      if (!selectedWandererEntity) {
        throw new Error("No wanderer entity is selected");
      }
      const selectedWandererEntityId = world.entities[selectedWandererEntity];
      const equipmentSlotId = world.entities[equipmentSlot];
      const equipmentEntityId = world.entities[equipmentEntity];
      const tx = await systems["system.CycleEquipment"].executeTyped(
        action,
        selectedWandererEntityId,
        equipmentSlotId,
        equipmentEntityId
      );
      const loot = getLoot(world, components, equipmentEntity);
      await toastPromise(tx.wait(), `Equip ${loot.name}...`, `${loot.name} equipped...`);
    },
    [world, systems, selectedWandererEntity]
  );
};
