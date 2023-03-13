import { useMaps } from "../mud/hooks/useMaps";
import BasicMap from "../components/Map/BasicMap";
import Map from "../components/Map";
import { useBossesDefeated } from "../mud/hooks/useBossesDefeated";
import { useWandererContext } from "../contexts/WandererContext";
import { useMemo } from "react";
import { useLifeCurrent } from "../mud/hooks/currents";

export function GlobalMaps() {
  const { cycleEntity } = useWandererContext();

  const basicMapEntities = useMaps("Global Basic");
  const randomMapEntities = useMaps("Global Random");
  const bossMapEntities = useMaps("Global Cycle Boss");
  console.log("basicMapEntities", basicMapEntities);

  const bossesDefeated = useBossesDefeated(cycleEntity);
  const lifeCurrent = useLifeCurrent(cycleEntity);

  const bossMapEntitiesUndefeated = useMemo(() => {
    // show up to 3 undefeated bosses
    return bossMapEntities.filter((entity) => !bossesDefeated.includes(entity)).slice(0, 3);
  }, [bossMapEntities, bossesDefeated]);

  return (
    <div className="flex flex-col">
      {!lifeCurrent && (
        <div className="text-dark-comment m-4">{"// you are out of life, passTurn fully restores life and mana"}</div>
      )}
      <div className="flex justify-around flex-wrap">
        <div className="flex flex-col mx-4">
          <h4 className="text-dark-comment">{"// Global Basic maps"}</h4>
          {basicMapEntities.map((entity) => (
            <BasicMap key={entity} entity={entity} />
          ))}
        </div>
        <div>
          <h4 className="text-dark-comment">{"// Global Random maps"}</h4>
          <div className="flex flex-col gap-y-4 mr-4">
            {randomMapEntities.map((entity) => (
              <Map key={entity} entity={entity} />
            ))}
          </div>
        </div>
        <div>
          <h4 className="text-dark-comment">{"// Global Boss maps"}</h4>
          <div className="flex flex-col gap-y-4 mr-4">
            {bossMapEntitiesUndefeated.map((entity) => (
              <Map key={entity} entity={entity} />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
