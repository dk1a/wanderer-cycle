//import Effect from "../Effect";
import { Button } from "../utils/Button/Button";
import { useWandererContext } from "../../contexts/WandererContext";
import { useCallback } from "react";
import { EffectSource } from "../../mud/utils/getEffect";
import { useCycleTurns } from "../../mud/hooks/turns";
import { MapData } from "../../mud/utils/getMaps";

export default function Map({ data }: { data: MapData }) {
  const { selectedWandererEntity, cycleEntity } = useWandererContext();

  const { entity, name, ilvl, effectTemplate } = data.lootData;

  const turns = useCycleTurns(cycleEntity);

  const onMapEnter = useCallback(() => {
    if (!selectedWandererEntity) {
      throw new Error("No selected wanderer entity");
    }
    console.log(
      "TODO add cycle combat activation",
      selectedWandererEntity,
      entity,
    );
  }, [entity, selectedWandererEntity]);

  return (
    <div className="border border-dark-400 w-56 h-62 p-4 flex flex-col bg-dark-500">
      <Button onClick={onMapEnter} disabled={!turns}>
        {name}
      </Button>
      <div className="text-dark-comment mt-1">
        <span className="text-dark-key">level: </span>
        <span className="text-dark-number">{ilvl}</span>
      </div>
      <div className="text-dark-comment">
        {/*<Effect
          entity={effect.entity}
          protoEntity={entity}
          removability={effect.removability}
          statmods={effect.statmods}
          effectSource={EffectSource.MAP}
        />*/}
      </div>
    </div>
  );
}
