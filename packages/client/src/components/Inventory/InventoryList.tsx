import { useOwnedEquipment } from "../../mud/hooks/useOwnedEquipment";
import { equipmentProtoEntityIds, equipmentPrototypes } from "../../mud/utils/equipment";
import { useMemo } from "react";
import InventorySection from "./InventorySection";
import InventoryHeader from "./InventoryHeader";

// TODO this looks like it should have an InventoryContext, with filtering and sorting and all that
const InventoryList = () => {
  const ownedEquipmentList = useOwnedEquipment();

  const presentProtoEntityIds = useMemo(() => {
    // extract unique prototypes of the owned equipment
    const presentProtoEntityIds = new Set(ownedEquipmentList.map(({ protoEntityId }) => protoEntityId));
    // the filter just uses the sorting order of `equipmentProtoEntityIds`
    return equipmentProtoEntityIds.filter((protoEntityId) => presentProtoEntityIds.has(protoEntityId));
  }, [ownedEquipmentList]);
  console.log("presentProtoEntityIds", presentProtoEntityIds);
  console.log("equipmentPrototypes", equipmentPrototypes);

  const separator = <hr className="h-px my-2 bg-dark-400 border-0" />;

  return (
    <div className="w-[60%] flex flex-col justify-center items-center">
      <div className="flex justify-start w-full m-2">
        <div className="text-2xl text-dark-comment">{"// inventory"}</div>
      </div>

      {/* TODO provide more data for statmods so they can be used for sorting as well
      <CustomSelect
        defaultValue={"Sort"}
        value={selectedSort}
        onChange={sortList}
        option={[
          { value: "name", name: "name" },
          { value: "ilvl", name: "ilvl" },
        ]}
      />*/}
      <div className="flex flex-col justify-center items-center">
        {presentProtoEntityIds.map((_protoEntityId) => (
          <div key={_protoEntityId} className="w-full">
            {separator}
            <div key={_protoEntityId} className="flex w-full justify-around">
              <InventoryHeader>{equipmentPrototypes[_protoEntityId]}</InventoryHeader>
              <InventorySection
                equipmentList={ownedEquipmentList.filter(({ protoEntityId }) => protoEntityId === _protoEntityId)}
              />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default InventoryList;
