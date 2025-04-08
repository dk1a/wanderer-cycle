import { useWandererContext } from "../../contexts/WandererContext";
import { useCallback } from "react";
import { useStashCustom } from "../../mud/stash";
import { getActiveGuise } from "../../mud/utils/guise";
import { getCycleTurns } from "../../mud/utils/turns";
import { useLevel } from "../../mud/hooks/charstat";
import { Button } from "../utils/Button/Button";
import { MapData } from "../../mud/utils/getMaps";
import { useMUD } from "../../MUDContext";

export default function BasicMap({ data }: { data: MapData }) {
  const { systemCalls } = useMUD();
  const { selectedWandererEntity, cycleEntity } = useWandererContext();

  const { entity, name, ilvl } = data.lootData;

  const guise = useStashCustom((state) => getActiveGuise(state, cycleEntity));
  const levelData = useLevel(cycleEntity, guise?.levelMul);
  const turns = useStashCustom((state) => getCycleTurns(state, cycleEntity));

  const onMapEnter = useCallback(() => {
    if (!selectedWandererEntity) {
      throw new Error("No selected wanderer entity");
    }
    systemCalls.activateCycleCombat(selectedWandererEntity, entity);
  }, [systemCalls, entity, selectedWandererEntity]);

  const isHighLevel = levelData !== undefined && ilvl - levelData?.level > 2;

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
