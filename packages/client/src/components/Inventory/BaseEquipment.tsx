import { EquipmentData } from "../../contexts/InventoryContext";
import { EffectStatmod } from "../Effect/EffectStatmod";
import CustomButton from "../UI/Button/CustomButton";
import Tippy from "@tippyjs/react";
import { right } from "@popperjs/core";
import { useState } from "react";

type BaseEquipmentProps = {
  equipmentData: EquipmentData;
  className?: string;
};

export default function BaseEquipment({ equipmentData, className }: BaseEquipmentProps) {
  const { name, ilvl, affixes } = equipmentData;
  const availableSlots = equipmentData.availableSlots;

  const [isAltPressed, setIsAltPressed] = useState(false);

  const handleKeyDown = (event: React.KeyboardEvent<HTMLDivElement>): void => {
    if (event.altKey) {
      setIsAltPressed(true);
    }
  };

  const handleKeyUp = (event: React.KeyboardEvent<HTMLDivElement>): void => {
    if (!event.altKey) {
      setIsAltPressed(false);
    }
  };

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
          <Tippy
            key={`${partId}${protoEntity}`}
            placement={right}
            trigger={"click"}
            offset={[0, -40]}
            className="m-0 p-0"
            arrow={true}
            content={
              <div className="border border-dark-400 bg-dark-500 m-[-10px] p-2">
                <div className="flex">
                  <span className="text-dark-number">{affixPrototype.tier}</span>
                  <span className="text-dark-string mx-2">{affixPrototype.name}</span>
                  <span className="text-dark-number">
                    {affixPrototype.min}-{affixPrototype.max}
                  </span>
                </div>
              </div>
            }
          >
            <div className="flex box-content flex-wrap cursor=pointer">
              <EffectStatmod protoEntity={statmod.protoEntity} value={value} />
              {/* TODO add global button to trigger this data: */}
              {/*{affixPrototype.tier} {affixPrototype.name}
          ({affixPrototype.min}-{affixPrototype.max})*/}
            </div>
          </Tippy>
        ))}
      </div>
      <div onKeyDown={handleKeyDown} onKeyUp={handleKeyUp} tabIndex={0}>
        {isAltPressed ? "alt najat" : "alt ne najat"}
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
