import Tippy from "@tippyjs/react";
import CustomButton from "../UI/Button/CustomButton";
import { left } from "@popperjs/core";
import { useInventoryContext } from "../../contexts/InventoryContext";
import BaseEquipmentDetails from "./BaseEquipmentDetails";

const CurrentEquipment = () => {
  const { equipmentSlots } = useInventoryContext();

  return (
    <section className="flex flex-col w-64 bg-dark-500 border border-dark-400 h-screen absolute top-16 right-0">
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
                affixes={equipped.affixes}
                ilvl={equipped.ilvl}
                name={equipped.name}
                className={"border border-dark-400 bg-dark-500 m-[-10px] p-2"}
              />
            ) : (
              <div className="bg-dark-500 w-36 h-16 text-center p-2 text-lg text-dark-300 m-[-10px] border border-dark-400">
                Take loot
              </div>
            )
          }
        >
          <div className="flex flex-wrap flex-col m-2 border border-dark-400 p-1">
            <div className="text-dark-200 text-[14px] flex flex-wrap ml-1">
              {name}:
              {equipped !== undefined ? (
                <p className="text-dark-type text-[14px] mx-1">{equipped.name}</p>
              ) : (
                <p className="text-dark-300 mx-2">empty</p>
              )}
            </div>
            {equipped !== undefined && (
              <div>
                <CustomButton style={{ marginTop: "5px", fontSize: "13px" }} onClick={() => unequip()}>
                  unequip
                </CustomButton>
              </div>
            )}
          </div>
        </Tippy>
      ))}
    </section>
  );
};

export default CurrentEquipment;
