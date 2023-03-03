import Tippy from "@tippyjs/react";
import CustomButton from "../UI/Button/CustomButton";
import { left } from "@popperjs/core";
import { useInventoryContext } from "../../contexts/InventoryContext";
import BaseEquipmentDetails from "./BaseEquipmentDetails";
import { EquipmentSummary } from "./EquipmentSummary";

export default function CurrentEquipment() {
  const { equipmentSlots } = useInventoryContext();
  console.log("equipment", equipmentSlots);

  return (
    <section className="flex flex-col w-64 bg-dark-500 border border-dark-400 h-full">
      <h4 className="col-span-3 text-center text-lg text-dark-type font-medium">Current Equipment</h4>
      {equipmentSlots.map(({ entity, name, equipped, unequip }) => (
        <Tippy
          key={entity}
          placement={left}
          trigger={"click"}
          offset={[0, 15]}
          content={
            equipped !== undefined ? (
              <BaseEquipmentDetails
                key={entity}
                data={equipped}
                className="border border-dark-400 bg-dark-500 m-[-10px] p-2"
              />
            ) : (
              <div className="bg-dark-500 w-36 h-16 text-center p-2 text-lg text-dark-300 m-[-10px] border border-dark-400">
                Take loot
              </div>
            )
          }
        >
          <div className="flex flex-wrap flex-col m-2 border border-dark-400 p-1">
            <div className="text-dark-200 text-[14px] flex ml-1">
              <div className="flex mr-1 whitespace-nowrap">{name}:</div>
              {equipped !== undefined ? (
                <div className="text-dark-method text-[13px]">{equipped.name}</div>
              ) : (
                <p className="text-dark-300">empty</p>
              )}
            </div>
            {equipped !== undefined && (
              <div className="flex justify-between items-center">
                <div className="ml-2">
                  <EquipmentSummary affixes={equipped.affixes} />
                </div>
                <div className="mr-2">
                  <CustomButton style={{ height: "25px", fontSize: "13px" }} onClick={() => unequip()}>
                    unequip
                  </CustomButton>
                </div>
              </div>
            )}
          </div>
        </Tippy>
      ))}
    </section>
  );
}
