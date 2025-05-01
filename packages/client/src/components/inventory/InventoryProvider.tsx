import { createContext, ReactNode, useContext, useMemo, useState } from "react";
import { Hex } from "viem";
import { useStashCustom } from "../../mud/stash";
import {
  EquipmentData,
  EquipmentSlot,
  EquipmentType,
  equipmentTypes,
  getEquipmentSlots,
  getOwnedEquipment,
} from "../../mud/utils/equipment";

export const inventorySortOptions = [
  { value: "ilvl", label: "ilvl" },
  { value: "name", label: "name" },
] as const;

export type InventorySortOption = (typeof inventorySortOptions)[number] | null;

export type EquipmentDataWithSlots = EquipmentData & {
  equippedToSlot: EquipmentSlot | undefined;
  availableSlots: EquipmentSlot[] | undefined;
};

type InventoryContextType = {
  sort: InventorySortOption;
  setSort: (sort: InventorySortOption) => void;
  filter: string;
  setFilter: (filter: string) => void;
  presentEquipmentTypes: EquipmentType[];
  equipmentList: EquipmentDataWithSlots[];
  equipmentSlots: EquipmentSlot[];
};

const InventoryContext = createContext<InventoryContextType | undefined>(
  undefined,
);

export const InventoryProvider = ({
  children,
  targetEntity,
}: {
  children: ReactNode;
  targetEntity: Hex;
}) => {
  const currentValue = useContext(InventoryContext);
  if (currentValue) throw new Error("InventoryProvider can only be used once");

  const [sort, setSort] = useState<InventorySortOption>(null);
  const [filter, setFilter] = useState<string>("");

  const equipmentSlots = useStashCustom((state) =>
    getEquipmentSlots(state, targetEntity),
  );

  // 1. Get all owned equipment
  const ownedEquipmentList = useStashCustom((state) =>
    getOwnedEquipment(state, targetEntity),
  );

  // 2. Filter it
  const filteredEquipmentList = useMemo(() => {
    return ownedEquipmentList.filter((equipment) => {
      return equipment.name.toLowerCase().includes(filter.toLowerCase());
    });
  }, [filter, ownedEquipmentList]);

  // 3. Sort it
  const sortedEquipmentList = useMemo(() => {
    if (sort === null) {
      return filteredEquipmentList;
    } else if (sort.value === "name") {
      return [...filteredEquipmentList].sort((a, b) =>
        a[sort.value].localeCompare(b[sort.value]),
      );
    } else if (sort.value === "ilvl") {
      return [...filteredEquipmentList].sort(
        (a, b) => b[sort.value] - a[sort.value],
      );
    } else {
      return filteredEquipmentList;
    }
  }, [sort, filteredEquipmentList]);

  // 4. Add equipment slot info
  const equipmentListWithSlots = useMemo(() => {
    return sortedEquipmentList.map((data): EquipmentDataWithSlots => {
      const equippedToSlot = equipmentSlots.find(
        ({ equippedEntity }) => data.entity === equippedEntity,
      );

      const availableSlots = (() => {
        if (equippedToSlot) return;
        return equipmentSlots.filter(({ allowedEquipmentTypes }) =>
          allowedEquipmentTypes.includes(data.equipmentType),
        );
      })();

      return {
        ...data,
        equippedToSlot,
        availableSlots,
      };
    });
  }, [sortedEquipmentList, equipmentSlots]);

  // 5. Omit the currently equipped equipment
  const equipmentList = useMemo(() => {
    return equipmentListWithSlots.filter(
      ({ equippedToSlot }) => equippedToSlot === undefined,
    );
  }, [equipmentListWithSlots]);

  // 6. Extract equipment types still present after filtering
  const presentEquipmentTypes = useMemo(() => {
    // extract unique types of the owned equipment
    const presentEquipmentTypes = new Set(
      equipmentList.map(({ equipmentType }) => equipmentType),
    );
    // the filter just uses the sorting order of `equipmentTypes`
    return equipmentTypes.filter((equipmentType) =>
      presentEquipmentTypes.has(equipmentType),
    );
  }, [equipmentList]);

  const value = {
    sort,
    setSort,
    filter,
    setFilter,
    presentEquipmentTypes,
    equipmentList,
    equipmentSlots,
  };
  return (
    <InventoryContext.Provider value={value}>
      {children}
    </InventoryContext.Provider>
  );
};

export const useInventoryContext = () => {
  const value = useContext(InventoryContext);
  if (!value) throw new Error("Must be used within an InventoryProvider");
  return value;
};
