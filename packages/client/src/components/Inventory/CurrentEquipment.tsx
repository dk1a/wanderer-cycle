import Tippy from "@tippyjs/react";
import CustomButton from "../UI/Button/CustomButton";
import { left } from "@popperjs/core";

const CurrentEquipment = ({ equipmentList, equipmentSlots }: any) => {
  const affixes = equipmentList.map((i) => i.affixes);
  console.log(equipmentSlots);

  return (
    <section className="flex flex-col w-64 bg-dark-500 border border-dark-400 h-screen absolute top-16 right-0">
      <h4 className="col-span-3 text-center text-lg text-dark-type font-medium">Current Equipment</h4>
      {equipmentSlots.map(({ entity, name, equipped, unequip }) => (
        <Tippy key={entity} placement={left} content={<span>Stats</span>}>
          <div className="flex flex-wrap m-2 border border-dark-400 p-1.5">
            <div className="text-dark-200">{name}:</div>
            {equipped == undefined ? (
              <>
                <div>
                  <div className="text-dark-type mx-1">{"equipped.name"}</div>
                </div>
                <CustomButton style={{ marginTop: "5px" }} onClick={() => unequip()}>
                  unequip
                </CustomButton>
              </>
            ) : (
              <div className="text-dark-300 mx-2">empty</div>
            )}
          </div>
        </Tippy>
      ))}
    </section>
  );
};

export default CurrentEquipment;
