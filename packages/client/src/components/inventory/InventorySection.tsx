import { useState } from "react";
import { Hex } from "viem";
import { EquipmentData, EquipmentType } from "../../mud/utils/equipment";
import { BaseLoot } from "./BaseLoot";
import { EquipmentSlotButtons } from "./EquipmentSlotButtons";
import { SlotsForEquipment } from "./InventoryProvider";

interface InventorySectionProps {
  ownerEntity: Hex;
  equipmentList: EquipmentData[];
  slotsForEquipment: Record<Hex, SlotsForEquipment>;
  equipmentType: EquipmentType;
}

export function InventorySection({
  ownerEntity,
  equipmentList,
  slotsForEquipment,
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
            <BaseLoot key={equipmentData.entity} lootData={equipmentData}>
              <EquipmentSlotButtons
                ownerEntity={ownerEntity}
                equipmentEntity={equipmentData.entity}
                slotsForEquipment={slotsForEquipment[equipmentData.entity]}
              />
            </BaseLoot>
          ))}
        </div>
      )}
    </div>
  );
}
