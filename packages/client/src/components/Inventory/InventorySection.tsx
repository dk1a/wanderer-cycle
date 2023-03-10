import { equipmentPrototypes } from "../../mud/utils/equipment";
import { EntityID } from "@latticexyz/recs";
import { useState } from "react";
import BaseEquipment from "./BaseEquipment";
import { EquipmentData } from "../../contexts/InventoryContext";

export default function InventorySection({
  equipmentList,
  protoEntityId,
}: {
  equipmentList: EquipmentData[];
  protoEntityId: EntityID;
}) {
  const [collapsed, setCollapsed] = useState(true);

  return (
    <div>
      <div className="w-1/3 cursor-pointer" onClick={() => setCollapsed(!collapsed)}>
        <h3 className="text-xl text-dark-200">
          {equipmentPrototypes[protoEntityId]}
          <span className="text-dark-300">{collapsed ? " >" : " v"}</span>
        </h3>
      </div>
      {collapsed && (
        <div className="flex justify-start flex-wrap w-auto">
          {equipmentList.map((equipmentData) => (
            <BaseEquipment key={equipmentData.entity} equipmentData={equipmentData} />
          ))}
        </div>
      )}
    </div>
  );
}
