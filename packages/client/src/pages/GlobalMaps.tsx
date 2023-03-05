import { useMaps } from "../mud/hooks/useMaps";
import BasicMap from "../components/Map/BasicMap";
import Map from "../components/Map";
import { useBossesDefeated } from "../mud/hooks/useBossesDefeated";
import { useWandererContext } from "../contexts/WandererContext";
import { useMemo } from "react";

export function GlobalMaps() {
  const basicMapEntities = useMaps("Global Basic");
  const randomMapEntities = useMaps("Global Random");

  const { cycleEntity } = useWandererContext();
  const bossMapEntities = useMaps("Global Cycle Boss");
  const bossesDefeated = useBossesDefeated(cycleEntity);
  const bossMapEntitiesUndefeated = useMemo(() => {
    // show up to 3 undefeated bosses
    return bossMapEntities.filter((entity) => !bossesDefeated.includes(entity)).slice(0, 3);
  }, [bossMapEntities, bossesDefeated]);

  return (
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
  );
}
