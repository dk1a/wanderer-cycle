import { EntityID } from "@latticexyz/recs";
import { createContext, ReactNode, useContext, useMemo, useState } from "react";
import { useEquipmentSlots } from "../mud/hooks/useEquipmentSlots";
import { useOwnedEquipment } from "../mud/hooks/useOwnedEquipment";
import { equipmentProtoEntityIds } from "../mud/utils/equipment";
import { LootData } from "../mud/utils/getLoot";
import { useWandererContext } from "./WandererContext";

export type InventorySortKey = "name" | "ilvl";

type InventoryContextType = {
  sort?: InventorySortKey;
  setSort: (sort?: InventorySortKey) => void;
  filter: string;
  setFilter: (filter: string) => void;
  presentProtoEntityIds: EntityID[];
  equipmentList: LootData[];
};

const InventoryContext = createContext<InventoryContextType | undefined>(undefined);

export const InventoryProvider = (props: { children: ReactNode }) => {
  const currentValue = useContext(InventoryContext);
  if (currentValue) throw new Error("InventoryProvider can only be used once");

  const [sort, setSort] = useState<InventorySortKey>();
  const [filter, setFilter] = useState<string>("");

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

  // 4. Extract prototype entities still present after filtering
  const presentProtoEntityIds = useMemo(() => {
    // extract unique prototypes of the owned equipment
    const presentProtoEntityIds = new Set(sortedEquipmentList.map(({ protoEntityId }) => protoEntityId));
    // the filter just uses the sorting order of `equipmentProtoEntityIds`
    return equipmentProtoEntityIds.filter((protoEntityId) => presentProtoEntityIds.has(protoEntityId));
  }, [sortedEquipmentList]);

  const value = {
    sort,
    setSort,
    filter,
    setFilter,
    presentProtoEntityIds,
    equipmentList: sortedEquipmentList,
    equipmentSlots,
  };
  return <InventoryContext.Provider value={value}>{props.children}</InventoryContext.Provider>;
};

export const useInventoryContext = () => {
  const value = useContext(InventoryContext);
  if (!value) throw new Error("Must be used within an InventoryProvider");
  return value;
};
