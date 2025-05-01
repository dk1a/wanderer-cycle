import { Hex } from "viem";
import { useSystemCalls } from "../../mud/SystemCallsProvider";
import { Button } from "../ui/Button";
import { EquipmentSummary } from "./EquipmentSummary";
import { EquipmentDataWithSlots } from "./InventoryProvider";

type BaseEquipmentProps = {
  ownerEntity: Hex;
  equipmentData: EquipmentDataWithSlots;
  className?: string;
};

export function BaseEquipment({
  ownerEntity,
  equipmentData,
  className,
}: BaseEquipmentProps) {
  const systemCalls = useSystemCalls();
  const { name, ilvl, affixes } = equipmentData;
  const availableSlots = equipmentData.availableSlots;

  return (
    <div className="text-dark-key p-1.5 flex flex-col justify-between border border-dark-400 bg-dark-500 w-64 m-2">
      <div className={className}>
        <div className="flex items-start justify-between">
          <div className="text-lg text-dark-method flex box-border items-start">
            <span>{name}</span>
          </div>
          <span className="text-dark-key ml-1">
            ilvl:<span className="ml-1 text-dark-number">{ilvl}</span>
          </span>
        </div>
        <EquipmentSummary affixes={affixes} />
      </div>
      {availableSlots && !equipmentData.equippedToSlot && (
        <div className="flex justify-around mt-1">
          {availableSlots.map((slotData) => (
            <Button
              key={slotData.slotEntity}
              onClick={() =>
                systemCalls.cycle.equip(
                  ownerEntity,
                  slotData.slotEntity,
                  equipmentData.entity,
                )
              }
            >
              equip
              {availableSlots.length > 1 && (
                <span className="text-dark-string"> {slotData.name}</span>
              )}
            </Button>
          ))}
        </div>
      )}
    </div>
  );
}
