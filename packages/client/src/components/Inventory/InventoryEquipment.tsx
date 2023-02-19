import { getLoot } from "../../mud/utils/getLoot";
import { EffectModifier } from "../Effect/EffectStatmod";

const InventoryEquipment = ({ equipmentData }: { equipmentData: ReturnType<typeof getLoot> }) => {
  const affixes = equipmentData.affixes;

  // TODO affixes are more than effects, they need either a separate component or an extended EffectModifier
  return (
    <div className="flex items-center justify-center flex-wrap w-1/2">
      <div className="text-dark-key p-2 flex flex-col border border-dark-400 w-72">
        <span className="text-xl text-dark-type flex-wrap flex">{equipmentData.name}</span>
        {affixes.map(({ protoEntity, value, partId, statmod }) => (
          <EffectModifier key={`${partId}${protoEntity}`} protoEntity={statmod.protoEntity} value={value} />
        ))}
      </div>
    </div>
  );
};

export default InventoryEquipment;
