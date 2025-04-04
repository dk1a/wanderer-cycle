import { useWandererContext } from "../../contexts/WandererContext";
import { useCallback } from "react";
import { useActiveGuise } from "../../mud/hooks/guise";
import { useLevel } from "../../mud/hooks/charstat";
import { Button } from "../utils/Button/Button";
import { useCycleTurns } from "../../mud/hooks/turns";
import { MapData } from "../../mud/utils/getMaps";

export default function BasicMap({ data }: { data: MapData }) {
  const { selectedWandererEntity, cycleEntity } = useWandererContext();

  const { entity, name, ilvl } = data.lootData;

  const guise = useActiveGuise(cycleEntity);
  const levelData = useLevel(cycleEntity, guise?.levelMul);
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
