import { useOwnedEquipment } from "../../mud/hooks/useOwnedEquipment";
import { equipmentProtoEntityIds, equipmentPrototypes } from "../../mud/utils/equipment";
import { useMemo, useState } from "react";
import InventorySection from "./InventorySection";
import InventoryHeader from "./InventoryHeader";
import CustomSelect from "../UI/Select/CustomSelect";
import CustomInput from "../UI/Input/CustomInput";

// TODO this looks like it should have an InventoryContext, with filtering and sorting and all that
const InventoryList = () => {
  const ownedEquipmentList = useOwnedEquipment();
  const [equipmentList, setEquipmentList] = useState(ownedEquipmentList);
  const [selectedSort, setSelectedSort] = useState("");
  const [searchQuery, setSearchQuery] = useState("");

  const sortedEquipmentList = useMemo(() => {
    if (selectedSort == "name") {
      return [...equipmentList].sort((a, b) => a[selectedSort].localeCompare(b[selectedSort]));
    } else if (selectedSort == "ilvl") {
      return [...equipmentList].sort((a, b) => a[selectedSort] - b[selectedSort]);
    }
    return equipmentList;
  }, [selectedSort, equipmentList]);

  const sortedAndSearchedEquipmentList = useMemo(() => {
    return sortedEquipmentList.filter((equipment) => equipment.name.toLowerCase().includes(searchQuery));
  }, [searchQuery, sortedEquipmentList]);

  const sortInventory = (sort) => {
    setSelectedSort(sort);
  };

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
        <CustomSelect
          defaultValue={"Sort"}
          value={selectedSort}
          onChange={sortInventory}
          option={[
            { value: "name", name: "name" },
            { value: "ilvl", name: "ilvl" },
          ]}
        />
        <CustomInput value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} placeholder={"Search..."} />
      </div>

      <div className="flex flex-col justify-center items-center">
        {presentProtoEntityIds.map((_protoEntityId) => (
          <div key={_protoEntityId} className="w-full">
            <div key={_protoEntityId} className={!searchQuery ? "flex flex-wrap" : "flex justify-center flex-wrap"}>
              {!searchQuery && (
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
            {!searchQuery && separator}
          </div>
        ))}
      </div>
    </div>
  );
};

export default InventoryList;
