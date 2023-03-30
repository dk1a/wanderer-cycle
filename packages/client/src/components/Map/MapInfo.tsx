import Effect from "../Effect";
import { EffectSource } from "../../mud/utils/getEffect";
import { LootData } from "../../mud/utils/getLoot";

export default function MapInfo({ data }: { data: LootData }) {
  const { entity, name, ilvl, effect } = data;

  return (
    <div className={"bg-dark-500 border border-dark-400 p-2 m-[-10px] w-52"}>
      <div className="flex justify-between items-start">
        <div>
          <span className="text-dark-type">{name}</span>
        </div>
        <div className="text-dark-key w-1/4">
          lvl: <span className="text-dark-number">{ilvl}</span>
        </div>
      </div>
      <div className="text-dark-comment">
        <Effect
          entity={effect.entity}
          protoEntity={entity}
          removability={effect.removability}
          statmods={effect.statmods}
          effectSource={EffectSource.MAP}
        />
      </div>
    </div>
  );
}
