import { Hex } from "viem";
import { useSystemCalls } from "../../mud/SystemCallsProvider";
import { Button } from "../ui/Button";
import { SlotsForEquipment } from "./InventoryProvider";

type EquipmentSlotButtonsProps = {
  ownerEntity: Hex;
  equipmentEntity: Hex;
  slotsForEquipment: SlotsForEquipment;
};

export function EquipmentSlotButtons({
  ownerEntity,
  equipmentEntity,
  slotsForEquipment,
}: EquipmentSlotButtonsProps) {
  const systemCalls = useSystemCalls();
  const availableSlots = slotsForEquipment.availableSlots;

  if (
    !availableSlots ||
    availableSlots.length === 0 ||
    slotsForEquipment.equippedToSlot
  ) {
    return <></>;
  }

  return (
    <div className="flex justify-around mt-1">
      {availableSlots.map((slotData) => (
        <Button
          key={slotData.slotEntity}
          onClick={() =>
            systemCalls.cycle.equip(
              ownerEntity,
              slotData.slotEntity,
              equipmentEntity,
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
  );
}
