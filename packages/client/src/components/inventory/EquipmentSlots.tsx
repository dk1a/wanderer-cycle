import { useMemo } from "react";
import { Tooltip } from "react-tooltip";
import { Hex } from "viem";
import { useSystemCalls } from "../../mud/SystemCallsProvider";
import { useStashCustom } from "../../mud/stash";
import { getEquipmentStrict } from "../../mud/utils/equipment";
import { useInventoryContext } from "./InventoryProvider";
import { BaseLoot } from "./BaseLoot";
import { Button } from "../ui/Button";

export function EquipmentSlots({ ownerEntity }: { ownerEntity: Hex }) {
  const { equipmentSlots } = useInventoryContext();
  return (
    <section className="flex flex-col min-w-64 bg-dark-500 border border-dark-400 h-full">
      <h4 className="col-span-3 text-center text-lg text-dark-type font-medium">
        Equipment Slots
      </h4>
      {equipmentSlots.map(({ slotEntity, equippedEntity, name }) => (
        <EquipmentSlot
          key={slotEntity}
          ownerEntity={ownerEntity}
          slotName={name}
          equippedEntity={equippedEntity}
        />
      ))}
    </section>
  );
}

interface EquipmentSlotProps {
  ownerEntity: Hex;
  slotName: string | undefined;
  equippedEntity: Hex | undefined;
}

function EquipmentSlot({
  ownerEntity,
  slotName,
  equippedEntity,
}: EquipmentSlotProps) {
  const systemCalls = useSystemCalls();
  const { slotsForEquipment } = useInventoryContext();
  const equipment = useStashCustom((state) => {
    if (equippedEntity === undefined) return;
    return getEquipmentStrict(state, equippedEntity);
  });

  const unequip = useMemo(() => {
    if (equippedEntity === undefined) return;
    const equippedToSlot = slotsForEquipment[equippedEntity].equippedToSlot;
    if (equippedToSlot === undefined) return;

    return () =>
      systemCalls.cycle.unequip(ownerEntity, equippedToSlot.slotEntity);
  }, [systemCalls, ownerEntity, equipment]);

  const uniqueId = `current-equipment-equipped-${equippedEntity}`;

  return (
    <div className="flex flex-wrap flex-col m-2 border border-dark-400 p-1">
      <div className="text-dark-200 text-[14px] flex ml-1">
        <div className="flex mr-1 whitespace-nowrap">{slotName}:</div>
        {equipment ? (
          <>
            <div id={uniqueId} className="text-dark-method text-sm">
              {equipment.name}
            </div>
            <Tooltip anchorSelect={`#${uniqueId}`} place={"right"}>
              <BaseLoot lootData={equipment} />
            </Tooltip>
          </>
        ) : (
          <p className="text-dark-300">empty</p>
        )}
      </div>
      {equipment !== undefined && unequip !== undefined && (
        <div className="mr-2">
          <Button onClick={unequip}>unequip</Button>
        </div>
      )}
    </div>
  );
}
