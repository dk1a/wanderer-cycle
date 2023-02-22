import { EffectStatmod } from "../Effect/EffectStatmod";
import { LootAffix } from "../../mud/utils/getLootAffix";

type BaseEquipmentDetails = {
  affixes: LootAffix[];
  ilvl: number;
};
const BaseEquipmentDetails = ({ affixes, ilvl }: BaseEquipmentDetails) => {
  return (
    <>
      <span className="text-dark-key">
        ilvl<span className="mx-2 text-dark-number">{ilvl}</span>
      </span>
      {affixes.map(({ protoEntity, value, partId, statmod }) => (
        <div className="flex box-content flex-wrap" key={`${partId}${protoEntity}`}>
          <EffectStatmod protoEntity={statmod.protoEntity} value={value} />
        </div>
      ))}
    </>
  );
};

export default BaseEquipmentDetails;
