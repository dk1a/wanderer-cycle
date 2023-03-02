import { EffectStatmod } from "../Effect/EffectStatmod";
import { LootData } from "../../mud/utils/getLoot";

export default function BaseEquipmentDetails({ data, className }: { data: LootData; className: string }) {
  const { name, ilvl, affixes } = data;
  return (
    <div className={className}>
      <span className="text-lg text-dark-method flex-wrap flex box-border">{name}</span>
      <span className="text-dark-key">
        ilvl<span className="mx-2 text-dark-number">{ilvl}</span>
      </span>
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
