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
import { getBaseStatmod } from "../../mud/utils/statmod";

export type InventorySortOption = {
  value: string;
  label: string;
};

export type EquipmentDataWithSlots = EquipmentData & {
  equippedToSlot: EquipmentSlot | undefined;
  availableSlots: EquipmentSlot[] | undefined;
};

type InventoryContextType = {
  inventorySortOptions: InventorySortOption[];
  sort: InventorySortOption | null;
  setSort: (sort: InventorySortOption | null) => void;
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

  const [sort, setSort] = useState<InventorySortOption | null>(null);
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

  // 3. Get the sort options based on filtered equipment
  const presentStatmods = useStashCustom((state) => {
    // extract unique statmods within the affixes of the owned equipment
    const presentStatmodEntities = [
      ...new Set(
        filteredEquipmentList
          .map(({ affixes }) =>
            affixes.map(({ affixPrototype }) => affixPrototype.statmodEntity),
          )
          .flat(),
      ),
    ];
    return presentStatmodEntities
      .map((entity) => getBaseStatmod(state, entity))
      .sort((a, b) => a.name.localeCompare(b.name));
  });
  const inventorySortOptions = useMemo(() => {
    return [
      { value: "ilvl", label: "ilvl" },
      { value: "name", label: "name" },
      ...presentStatmods.map((statmod) => ({
        value: statmod.entity,
        label: statmod.name,
      })),
    ];
  }, [presentStatmods]);

  // 4. Sort it
  const sortedEquipmentList = useMemo(() => {
    const sortValue = sort === null ? null : sort.value;
    if (sortValue === null) {
      return filteredEquipmentList;
    } else if (sortValue === "name") {
      return [...filteredEquipmentList].sort((a, b) =>
        a[sortValue].localeCompare(b[sortValue]),
      );
    } else if (sortValue === "ilvl") {
      return [...filteredEquipmentList].sort(
        (a, b) => b[sortValue] - a[sortValue],
      );
    } else {
      return [...filteredEquipmentList].sort((a, b) => {
        const aAffix = a.affixes.find(
          (affix) => affix.affixPrototype.statmodEntity === sortValue,
        );
        const bAffix = b.affixes.find(
          (affix) => affix.affixPrototype.statmodEntity === sortValue,
        );

        // revert to ilvl sorting if the statmod doesn't exist on either item
        if (!aAffix && !bAffix) return a.ilvl - b.ilvl;
        // sort by affix value of the selected statmod
        return (bAffix?.value ?? 0) - (aAffix?.value ?? 0);
      });
    }
  }, [sort, filteredEquipmentList]);

  // 5. Add equipment slot info
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

  // 6. Omit the currently equipped equipment
  const equipmentList = useMemo(() => {
    return equipmentListWithSlots.filter(
      ({ equippedToSlot }) => equippedToSlot === undefined,
    );
  }, [equipmentListWithSlots]);

  // 7. Extract equipment types still present after filtering
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
    inventorySortOptions,
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
