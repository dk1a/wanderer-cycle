import { EffectStatmod } from "../Effect/EffectStatmod";
import { LootAffix } from "../../mud/utils/getLootAffix";

<<<<<<< HEAD
type BaseEquipmentDetailsData = {
  affixes: LootAffix[];
  ilvl: number;
  name: string;
  className: StyleSheet;
};
const BaseEquipmentDetails = ({ affixes, ilvl, name, className }: BaseEquipmentDetailsData) => {
  return (
    <div className={className}>
      <span className="text-lg text-dark-type flex-wrap flex box-border">{name}</span>
=======
type BaseEquipmentDetails = {
  affixes: LootAffix[];
  ilvl: number;
};
const BaseEquipmentDetails = ({ affixes, ilvl }: BaseEquipmentDetails) => {
  return (
    <>
>>>>>>> 83f854c (BaseEquipmentDetails, data and styles)
      <span className="text-dark-key">
        ilvl<span className="mx-2 text-dark-number">{ilvl}</span>
      </span>
      {affixes.map(({ protoEntity, value, partId, statmod }) => (
        <div className="flex box-content flex-wrap" key={`${partId}${protoEntity}`}>
          <EffectStatmod protoEntity={statmod.protoEntity} value={value} />
        </div>
      ))}
<<<<<<< HEAD
    </div>
=======
    </>
>>>>>>> 83f854c (BaseEquipmentDetails, data and styles)
  );
};

export default BaseEquipmentDetails;
