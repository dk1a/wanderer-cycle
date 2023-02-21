import { useOwnedEquipment } from "../../mud/hooks/useOwnedEquipment";
import { equipmentProtoEntityIds, equipmentPrototypes } from "../../mud/utils/equipment";
import { useMemo, useState } from "react";
import InventorySection from "./InventorySection";
import InventoryHeader from "./InventoryHeader";
import InventoryFilter from "./InventoryFilter";

// TODO this looks like it should have an InventoryContext, with filtering and sorting and all that
const InventoryList = () => {
  const ownedEquipmentList = useOwnedEquipment();
  const [filter, setFilter] = useState({ sort: "", query: "" });

  const sortedEquipmentList = useMemo(() => {
    if (filter.sort == "name") {
      return [...ownedEquipmentList].sort((a, b) => a[filter.sort].localeCompare(b[filter.sort]));
    } else if (filter.sort == "ilvl") {
      return [...ownedEquipmentList].sort((a, b) => b[filter.sort] - a[filter.sort]);
    }
    return ownedEquipmentList;
  }, [filter.sort, ownedEquipmentList]);

  const sortedAndSearchedEquipmentList = useMemo(() => {
    return sortedEquipmentList.filter((equipment) => equipment.name.toLowerCase().includes(filter.query.toLowerCase()));
  }, [filter.query, sortedEquipmentList]);

  const presentProtoEntityIds = useMemo(() => {
    // extract unique prototypes of the owned equipment
    const presentProtoEntityIds = new Set(ownedEquipmentList.map(({ protoEntityId }) => protoEntityId));
    // the filter just uses the sorting order of `equipmentProtoEntityIds`
    return equipmentProtoEntityIds.filter((protoEntityId) => presentProtoEntityIds.has(protoEntityId));
  }, [ownedEquipmentList]);
  const separator = <hr className="h-px my-2 bg-dark-400 border-0" />;

  return (
    <div className="w-[60%] flex flex-col justify-center items-center">
      <div className="flex justify-start w-full m-2">
        <div className="text-2xl text-dark-comment">{"// inventory"}</div>
        <InventoryFilter filter={filter} setFilter={setFilter} />
      </div>

      <div className="flex flex-col justify-center items-center">
        {presentProtoEntityIds.map((_protoEntityId) => (
          <div key={_protoEntityId} className="w-full">
            <div
              key={_protoEntityId}
              className={!filter.query ? "flex flex-wrap flex-col" : "flex flex-col justify-center flex-wrap"}
            >
              {!filter.query && (
                <div className="w-1/3">
                  <InventoryHeader>{equipmentPrototypes[_protoEntityId]}</InventoryHeader>
                </div>
              )}
              <div className="w-auto">
                <InventorySection
                  equipmentList={sortedAndSearchedEquipmentList.filter(
                    ({ protoEntityId }) => protoEntityId === _protoEntityId
                  )}
                />
              </div>
            </div>
            {!filter.query && separator}
          </div>
        ))}
      </div>
    </div>
  );
};

export default InventoryList;
