import { EquipmentData } from "../../contexts/InventoryContext";
import { EffectStatmod } from "../Effect/EffectStatmod";
import CustomButton from "../UI/Button/CustomButton";
import { toast } from "react-toastify";

type BaseEquipmentProps = {
  equipmentData: EquipmentData;
  className?: string;
};

export default function BaseEquipment({ equipmentData, className }: BaseEquipmentProps) {
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
        {affixes.map(({ protoEntity, value, partId, statmod }) => (
          <div className="flex box-content flex-wrap" key={`${partId}${protoEntity}`}>
            <EffectStatmod protoEntity={statmod.protoEntity} value={value} />
            {/* TODO add global button to trigger this data: */}
            {/*{affixPrototype.tier} {affixPrototype.name}
          ({affixPrototype.min}-{affixPrototype.max})*/}
          </div>
        ))}
      </div>
      {availableSlots && !equipmentData.equippedToSlot && (
        <div className="flex justify-around mt-1">
          {availableSlots.map((slotData) => (
            <CustomButton
              key={slotData.entity}
              style={{ width: "80px", fontSize: "12px", padding: "5px", border: "none", marginTop: "5px" }}
              onClick={() => {
                toast.success("equipped", {
                  style: {
                    borderRadius: "0",
                    padding: "10px",
                    border: "1px solid #3c3c3c",
                    backgroundColor: "#252526",
                  },
                  icon: false,
                  position: "bottom-right",
                  autoClose: 2500,
                  hideProgressBar: false,
                  closeOnClick: true,
                  pauseOnHover: true,
                  draggable: true,
                  theme: "dark",
                });
                slotData.equip();
              }}
            >
              equip
              {availableSlots.length > 1 && <span className="text-dark-string">{slotData.name}</span>}
            </CustomButton>
          ))}
        </div>
      )}
    </div>
  );
}
