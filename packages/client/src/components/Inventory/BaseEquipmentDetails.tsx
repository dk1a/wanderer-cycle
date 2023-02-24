import { EffectStatmod } from "../Effect/EffectStatmod";
import { LootAffix } from "../../mud/utils/getLootAffix";

type BaseEquipmentDetailsData = {
  affixes: LootAffix[];
  ilvl: number;
  name: string;
  className: string;
};
const BaseEquipmentDetails = ({ affixes, ilvl, name, className }: BaseEquipmentDetailsData) => {
  return (
    <div className={className}>
      <span className="text-lg text-dark-method flex-wrap flex box-border">{name}</span>
      <span className="text-dark-key">
        ilvl<span className="mx-2 text-dark-number">{ilvl}</span>
      </span>
      {affixes.map(({ protoEntity, value, partId, statmod }) => (
        <div className="flex box-content flex-wrap" key={`${partId}${protoEntity}`}>
          <EffectStatmod protoEntity={statmod.protoEntity} value={value} />
        </div>
      ))}
    </div>
  );
};

export default BaseEquipmentDetails;
