import { useCallback } from "react";
import { useStashCustom } from "../../mud/stash";
import { useWandererContext } from "../../mud/WandererProvider";
import { getActiveGuise } from "../../mud/utils/guise";
import { getCycleTurns } from "../../mud/utils/turns";
import { MapData } from "../../mud/utils/getMap";
import { getLevel } from "../../mud/utils/charstat";
import { useSystemCalls } from "../../mud/SystemCallsProvider";
import { Button } from "../ui/Button";

export function BasicMap({ data }: { data: MapData }) {
  const systemCalls = useSystemCalls();
  const { cycleEntity } = useWandererContext();

  const { entity, name, ilvl } = data;

  const guise = useStashCustom((state) => getActiveGuise(state, cycleEntity));
  const levelData = useStashCustom((state) =>
    getLevel(state, cycleEntity, guise?.levelMul),
  );
  const turns = useStashCustom((state) => getCycleTurns(state, cycleEntity));

  const onMapEnter = useCallback(() => {
    if (!cycleEntity) {
      throw new Error("No cycle entity");
    }
    systemCalls.cycle.activateCombat(cycleEntity, entity);
  }, [systemCalls, entity, cycleEntity]);

  const isHighLevel =
    levelData?.level !== undefined && ilvl - levelData.level > 2;

  return (
    <>
      <div className="grid grid-cols-3 bg-dark-500 w-48 py-2 px-1">
        <Button
          className="col-span-2 mr-2"
          onClick={onMapEnter}
          disabled={!turns}
        >
          {name}
        </Button>
        <span className="whitespace-nowrap">
          <span className="text-dark-key">level: </span>
          <span className={isHighLevel ? "text-red-400" : "text-dark-number"}>
            {ilvl}
          </span>
        </span>
      </div>
    </>
  );
}
