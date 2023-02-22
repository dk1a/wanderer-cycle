import Tippy from "@tippyjs/react";
import CustomButton from "../UI/Button/CustomButton";
import { left } from "@popperjs/core";
import { EffectModifier } from "../Effect/EffectStatmod";
import { useInventoryContext } from "../../contexts/InventoryContext";

const CurrentEquipment = () => {
  const { equipmentSlots } = useInventoryContext();
  console.log("equipmentSlots", equipmentSlots);

  return (
    <section className="flex flex-col w-64 bg-dark-500 border border-dark-400 h-screen absolute top-16 right-0">
      <h4 className="col-span-3 text-center text-lg text-dark-type font-medium">Current Equipment</h4>
      {equipmentSlots.map(({ entity, name, equipped, unequip }) => (
        <Tippy
          key={entity}
          placement={left}
          content={
            equipped !== undefined ? (
              <EffectModifier protoEntity={equipped.protoEntity} value={equipped.affixes.value} />
            ) : (
              <div>Take loot</div>
            )
          }
        >
          <div className="flex flex-wrap flex-col m-2 border border-dark-400 p-1">
            <div className="text-dark-200 text-[14px] flex flex-wrap ml-1">
              {name}:
              {equipped !== undefined ? (
                <div className="text-dark-type text-[14px] ml-1">{equipped.name}</div>
              ) : (
                <div className="text-dark-300 mx-2">empty</div>
              )}
            </div>
            {equipped !== undefined && (
              <div className="w-">
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
