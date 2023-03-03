import { EffectStatmod } from "../Effect/EffectStatmod";
import { LootData } from "../../mud/utils/getLoot";

export default function BaseEquipmentDetails({ data, className }: { data: LootData; className: string }) {
  const { name, ilvl, affixes } = data;
  return (
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
  );
}
