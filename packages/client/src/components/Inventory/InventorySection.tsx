import InventoryEquipment from "./InventoryEquipment";
import { useOwnedEquipment } from "../../mud/hooks/useOwnedEquipment";

const InventorySection = ({ equipmentList }: { equipmentList: ReturnType<typeof useOwnedEquipment> }) => {
  return (
    <div className="flex items-center justify-center flex-wrap w-1/2">
      {equipmentList.map((equipmentData) => (
        <InventoryEquipment key={equipmentData.entity} equipmentData={equipmentData} />
      ))}
    </div>
  );
};

export default InventorySection;
