import InventoryEquipment from "./InventoryEquipment";
import { useOwnedEquipment } from "../../mud/hooks/useOwnedEquipment";
import { equipmentPrototypes } from "../../mud/utils/equipment";
import { EntityID } from "@latticexyz/recs";
import { useState } from "react";

export default function InventorySection({
  equipmentList,
  protoEntityId,
}: {
  equipmentList: ReturnType<typeof useOwnedEquipment>;
  protoEntityId: EntityID;
}) {
  const [vision, setVision] = useState(true);

  return (
    <div>
      <div className="w-1/3 cursor-pointer" onClick={() => setVision(!vision)}>
        <h3 className="text-xl text-dark-200">{equipmentPrototypes[protoEntityId]}</h3>
      </div>
      {vision && (
        <div className="flex justify-start flex-wrap w-auto">
          {equipmentList.map((equipmentData) => (
            <InventoryEquipment key={equipmentData.entity} equipmentData={equipmentData} />
          ))}
        </div>
      )}
    </div>
  );
}
