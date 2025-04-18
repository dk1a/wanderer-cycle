import { useCallback } from "react";
//import Effect from "../Effect";
import { Button } from "../utils/Button/Button";
import { useWandererContext } from "../../contexts/WandererContext";
import { useStashCustom } from "../../mud/stash";
import { EffectSource } from "../../mud/utils/getEffect";
import { getCycleTurns } from "../../mud/utils/turns";
import { MapData } from "../../mud/utils/getMap";
import { useMUD } from "../../MUDContext";

export default function Map({ data }: { data: MapData }) {
  const { systemCalls } = useMUD();
  const { cycleEntity } = useWandererContext();

  const { entity, name, ilvl, effectTemplate } = data.lootData;

  const turns = useStashCustom((state) => getCycleTurns(state, cycleEntity));

  const onMapEnter = useCallback(() => {
    if (!cycleEntity) {
      throw new Error("No cycle entity");
    }
    systemCalls.activateCycleCombat(cycleEntity, entity);
  }, [systemCalls, entity, cycleEntity]);

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
