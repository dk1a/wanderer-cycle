import { EquipmentData } from "../../contexts/InventoryContext";
import CustomButton from "../UI/Button/CustomButton";
import BaseEquipmentDetails from "./BaseEquipmentDetails";

const InventoryEquipment = ({ equipmentData }: { equipmentData: EquipmentData }) => {
  const affixes = equipmentData.affixes;

  // TODO affixes are more than effects, they need either a separate component or an extended EffectModifier
  return (
    <div className="text-dark-key p-2 flex flex-col justify-between border border-dark-400 w-[220px] h-auto m-2">
      <BaseEquipmentDetails affixes={affixes} ilvl={equipmentData.ilvl} name={equipmentData.name} />
      <div className="flex justify-around mt-1">
        {equipmentData.availableSlots.map((slotData) => (
          <CustomButton
            key={slotData.entity}
            style={{ width: "80px", fontSize: "12px", padding: "0" }}
            onClick={() => slotData.equip()}
          >
            equip
            {equipmentData.availableSlots.length > 1 && <span className="text-dark-string"> ({slotData.name})</span>}
          </CustomButton>
        ))}
      </div>
    </div>
  );
};

export default InventoryEquipment;
