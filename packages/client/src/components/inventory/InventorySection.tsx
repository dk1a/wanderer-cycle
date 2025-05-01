import { useState } from "react";
import { Hex } from "viem";
import { EquipmentType } from "../../mud/utils/equipment";
import { BaseEquipment } from "./BaseEquipment";
import { EquipmentDataWithSlots } from "./InventoryProvider";

interface InventorySectionProps {
  ownerEntity: Hex;
  equipmentList: EquipmentDataWithSlots[];
  equipmentType: EquipmentType;
}

export function InventorySection({
  ownerEntity,
  equipmentList,
  equipmentType,
}: InventorySectionProps) {
  const [collapsed, setCollapsed] = useState(true);

  return (
    <div>
      <div
        className="w-1/3 cursor-pointer"
        onClick={() => setCollapsed(!collapsed)}
      >
        <h3 className="text-xl text-dark-200">
          {equipmentType}
          <span className="text-dark-300">{collapsed ? " >" : " v"}</span>
        </h3>
      </div>
      {collapsed && (
        <div className="flex justify-start flex-wrap w-auto">
          {equipmentList.map((equipmentData) => (
            <BaseEquipment
              key={equipmentData.entity}
              ownerEntity={ownerEntity}
              equipmentData={equipmentData}
            />
          ))}
        </div>
      )}
    </div>
  );
}
