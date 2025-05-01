import { Hex } from "viem";
import { useInventoryContext } from "./InventoryProvider";
import { InventorySection } from "./InventorySection";
import { InventoryFilter } from "./InventoryFilter";

export function InventoryList({ ownerEntity }: { ownerEntity: Hex }) {
  const { equipmentList, presentEquipmentTypes, filter } =
    useInventoryContext();

  const separator = <hr className="h-px my-2 bg-dark-400 border-0 " />;
  return (
    <div className="w-full flex flex-col ml-24">
      <InventoryFilter />
      <div className="flex flex-col justify-center items-center">
        {presentEquipmentTypes.map((equipmentType) => (
          <div key={equipmentType} className="w-full">
            <div
              className={
                !filter
                  ? "flex flex-col justify-start w-full flex-wrap"
                  : "flex flex-col justify-center flex-wrap"
              }
            >
              <InventorySection
                ownerEntity={ownerEntity}
                equipmentType={equipmentType}
                equipmentList={equipmentList.filter(
                  (equipment) => equipment.equipmentType === equipmentType,
                )}
              />
            </div>
            {separator}
          </div>
        ))}
      </div>
    </div>
  );
}
