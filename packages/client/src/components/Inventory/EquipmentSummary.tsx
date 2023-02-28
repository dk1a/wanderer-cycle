import { EffectStatmod } from "../Effect/EffectStatmod";
import { LootAffix } from "../../mud/utils/getLootAffix";

type EquipmentSummaryData = {
  affixes: LootAffix[];
};
export function EquipmentSummary({ affixes }: EquipmentSummaryData) {
  return (
    <div className="">
      {affixes.map(({ protoEntity, value, partId, statmod }) => (
        <div className="flex box-content flex-wrap" key={`${partId}${protoEntity}`}>
          <EffectStatmod protoEntity={statmod.protoEntity} value={value} />
        </div>
      ))}
    </div>
  );
}
