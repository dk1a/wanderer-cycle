import { EquipmentData } from "../../contexts/InventoryContext";
import { EffectStatmod } from "../Effect/EffectStatmod";
import CustomButton from "../UI/Button/CustomButton";
import { useEffect, useState } from "react";

type BaseEquipmentProps = {
  equipmentData: EquipmentData;
  className?: string;
};

export default function BaseEquipment({ equipmentData, className }: BaseEquipmentProps) {
  const { name, ilvl, affixes } = equipmentData;
  const availableSlots = equipmentData.availableSlots;

  const [isAltPressed, setIsAltPressed] = useState<boolean>(false);

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent): void => {
      if (event.altKey) {
        setIsAltPressed(true);
      }
    };

    const handleKeyUp = (event: KeyboardEvent): void => {
      if (!event.altKey) {
        setIsAltPressed(false);
      }
    };

    document.addEventListener("keydown", handleKeyDown);
    document.addEventListener("keyup", handleKeyUp);

    return () => {
      document.removeEventListener("keydown", handleKeyDown);
      document.removeEventListener("keyup", handleKeyUp);
    };
  }, []);

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
        {affixes.map(({ protoEntity, value, partId, statmod, affixPrototype }) => (
          <div key={`${partId}${protoEntity}`}>
            {isAltPressed ? (
              <div className="flex box-content flex-wrap text-[14px]">
                <div className="flex">
                  <span className="text-dark-string">+</span>
                  <span className="text-dark-number">{affixPrototype.tier}</span>
                  <span className="text-dark-string">
                    (
                    <span className="text-dark-number">
                      {affixPrototype.min}-{affixPrototype.max}
                    </span>
                    )
                  </span>
                  <span className="text-dark-string mx-2">{affixPrototype.name}</span>
                </div>
              </div>
            ) : (
              <EffectStatmod protoEntity={statmod.protoEntity} value={value} />
            )}
          </div>
        ))}
      </div>
      {availableSlots && !equipmentData.equippedToSlot && (
        <div className="flex justify-around mt-1">
          {availableSlots.map((slotData) => (
            <CustomButton
              key={slotData.entity}
              style={{ width: "80px", fontSize: "12px", padding: "5px", border: "none", marginTop: "5px" }}
              onClick={() => slotData.equip()}
            >
              equip
              {availableSlots.length > 1 && <span className="text-dark-string"> {slotData.name}</span>}
            </CustomButton>
          ))}
        </div>
      )}
    </div>
  );
}
