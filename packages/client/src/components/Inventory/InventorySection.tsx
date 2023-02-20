import InventoryEquipment from "./InventoryEquipment";
import { useOwnedEquipment } from "../../mud/hooks/useOwnedEquipment";
import { useState } from "react";

const InventorySection = ({ equipmentList }: { equipmentList: ReturnType<typeof useOwnedEquipment> }) => {
  const [inventoryList, setInventoryList] = useState(equipmentList);

  return (
    <div className="flex justify-center flex-wrap">
      {equipmentList.map((equipmentData) => (
        <InventoryEquipment key={equipmentData.entity} equipmentData={equipmentData} />
      ))}
    </div>
  );
};

export default InventorySection;
