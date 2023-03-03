import { EntityID } from "@latticexyz/recs";
import { createContext, ReactNode, useContext, useMemo, useState } from "react";
import { EquipmentAction, useChangeCycleEquipment } from "../mud/hooks/useChangeCycleEquipment";
import { EquipmentSlot, useEquipmentSlots } from "../mud/hooks/useEquipmentSlots";
import { useOwnedEquipment } from "../mud/hooks/useOwnedEquipment";
import { equipmentProtoEntityIds } from "../mud/utils/equipment";
import { LootData } from "../mud/utils/getLoot";
import { useWandererContext } from "./WandererContext";

export type InventorySortKey = "ilvl" | "name";

export type EquipmentSlotWithEquip = EquipmentSlot & { equip: () => void };

export type EquipmentData = LootData & {
  equippedToSlot: EquipmentSlot;
  availableSlots: EquipmentSlotWithEquip[];
};

type InventoryContextType = {
  sort: InventorySortKey | undefined;
  setSort: (sort: InventorySortKey | undefined) => void;
  filter: string;
  setFilter: (filter: string) => void;
  checked: boolean;
  setChecked: (checked: boolean) => void;
  presentProtoEntityIds: EntityID[];
  equipmentList: LootData[];
  equipmentSlots: ReturnType<typeof useEquipmentSlots>;
};

const InventoryContext = createContext<InventoryContextType | undefined>(undefined);

export const InventoryProvider = (props: { children: ReactNode }) => {
  const currentValue = useContext(InventoryContext);
  if (currentValue) throw new Error("InventoryProvider can only be used once");

  const [sort, setSort] = useState<InventorySortKey | undefined>("ilvl");
  const [filter, setFilter] = useState<string>("");
  const [checked, setChecked] = useState<boolean>(true);

  const changeCycleEquipment = useChangeCycleEquipment();
  const { cycleEntity } = useWandererContext();
  const equipmentSlots = useEquipmentSlots(cycleEntity);

  // 1. Get all owned equipment
  const ownedEquipmentList = useOwnedEquipment();

  // 2. Filter it
  const filteredEquipmentList = useMemo(() => {
    return ownedEquipmentList.filter((equipment) => {
      return equipment.name.toLowerCase().includes(filter.toLowerCase());
    });
  }, [filter, ownedEquipmentList]);

  // 3. Sort it
  const sortedEquipmentList = useMemo(() => {
    if (sort === "name") {
      return [...filteredEquipmentList].sort((a, b) => a[sort].localeCompare(b[sort]));
    } else if (sort === "ilvl") {
      return [...filteredEquipmentList].sort((a, b) => b[sort] - a[sort]);
    }
    return filteredEquipmentList;
  }, [sort, filteredEquipmentList]);

  // 4. Add equipment slot info
  const equipmentListWithSlots = useMemo(() => {
    return sortedEquipmentList.map((data) => {
      // get the
      const equippedToSlot = equipmentSlots.find(({ equipped }) => data.entity === equipped?.entity);

      const availableSlots = (() => {
        if (equippedToSlot) return;
        const equippableToSlots = equipmentSlots.filter(({ equipmentProtoEntityIds }) =>
          equipmentProtoEntityIds.includes(data.protoEntityId)
        );
        return equippableToSlots.map((slotData) => ({
          ...slotData,
          equip: () => changeCycleEquipment(EquipmentAction.EQUIP, slotData.entity, data.entity),
        }));
      })();

      return {
        ...data,
        equippedToSlot,
        availableSlots,
      };
    });
  }, [sortedEquipmentList, equipmentSlots, changeCycleEquipment]);

  // 5. Omit the currently equipped equipment
  const equipmentList = useMemo(() => {
    return equipmentListWithSlots.filter(({ equippedToSlot }) => equippedToSlot === undefined);
  }, [equipmentListWithSlots]);

  // 6. Extract prototype entities still present after filtering
  const presentProtoEntityIds = useMemo(() => {
    // extract unique prototypes of the owned equipment
    const presentProtoEntityIds = new Set(equipmentList.map(({ protoEntityId }) => protoEntityId));
    // the filter just uses the sorting order of `equipmentProtoEntityIds`
    return equipmentProtoEntityIds.filter((protoEntityId) => presentProtoEntityIds.has(protoEntityId));
  }, [equipmentList]);

  const value = {
    sort,
    setSort,
    filter,
    setFilter,
    checked,
    setChecked,
    presentProtoEntityIds,
    equipmentList,
    equipmentSlots,
  };
  return <InventoryContext.Provider value={value}>{props.children}</InventoryContext.Provider>;
};

export const useInventoryContext = () => {
  const value = useContext(InventoryContext);
  if (!value) throw new Error("Must be used within an InventoryProvider");
  return value;
};
