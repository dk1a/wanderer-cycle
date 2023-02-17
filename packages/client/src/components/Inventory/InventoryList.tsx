import { useOwnedEquipment } from "../../mud/hooks/useOwnedEquipment";
import { equipmentProtoEntityIds, equipmentPrototypes } from "../../mud/utils/equipment";
import { useMemo } from "react";
import InventorySection from "./InventorySection";

// TODO this looks like it should have an InventoryContext, with filtering and sorting and all that
const InventoryList = () => {
  const ownedEquipmentList = useOwnedEquipment();

  const presentProtoEntityIds = useMemo(() => {
    // extract unique prototypes of the owned equipment
    const presentProtoEntityIds = new Set(ownedEquipmentList.map(({ protoEntityId }) => protoEntityId));
    // the filter just uses the sorting order of `equipmentProtoEntityIds`
    return equipmentProtoEntityIds.filter((protoEntityId) => presentProtoEntityIds.has(protoEntityId));
  }, [ownedEquipmentList]);

  return (
    <div className="flex flex-col justify-center items-center">
      <div className="flex items-center justify-center">
        <div className="text-2xl text-dark-comment">{"// inventory"}</div>
      </div>

      {/* TODO to implement sorting an we need a full optimistic data getter
      <CustomSelect
        defaultValue={"Sort"}
        value={selectedSort}
        onChange={sortList}
        option={[
          { value: "title", name: "sorting by name" },
          { value: "type", name: "sorting by type" },
          { value: "stats", name: "sorting by stats" },
        ]}
      />*/}

      {presentProtoEntityIds.map(
        (
          _protoEntityId // TODO add styles (and maybe move the prototype header to Section?)
        ) => (
          <div key={_protoEntityId}>
            <div>{equipmentPrototypes[_protoEntityId]}</div>
            <div className="flex items-center justify-center flex-wrap w-1/2">
              <InventorySection
                equipmentList={ownedEquipmentList.filter(({ protoEntityId }) => protoEntityId === _protoEntityId)}
              />
            </div>
          </div>
        )
      )}
    </div>
  );
};

export default InventoryList;
