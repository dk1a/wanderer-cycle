import { useCallback } from "react";
import { useWandererContext } from "../../mud/WandererProvider";
import { useStashCustom } from "../../mud/stash";
import { getCycleTurns } from "../../mud/utils/turns";
import { MapData } from "../../mud/utils/getMap";
import { useSystemCalls } from "../../mud/SystemCallsProvider";
import { Button } from "../ui/Button";
import { EffectStatmods } from "../effect/EffectStatmods";

export function Map({ data }: { data: MapData }) {
  const systemCalls = useSystemCalls();
  const { cycleEntity } = useWandererContext();

  const turns = useStashCustom((state) => getCycleTurns(state, cycleEntity));

  const onMapEnter = useCallback(() => {
    if (!cycleEntity) {
      throw new Error("No cycle entity");
    }
    systemCalls.cycle.activateCombat(cycleEntity, data.entity);
  }, [systemCalls, data.entity, cycleEntity]);

  return (
    <div className="border border-dark-400 w-56 h-62 p-4 flex flex-col bg-dark-500">
      <Button onClick={onMapEnter} disabled={!turns}>
        {data.lootData.name}
      </Button>
      <div className="text-dark-comment mt-1">
        <span className="text-dark-key">level: </span>
        <span className="text-dark-number">{data.lootData.ilvl}</span>
      </div>
      <div className="text-dark-comment">
        <EffectStatmods statmods={data.lootData.effectTemplate.statmods} />
      </div>
    </div>
  );
}
