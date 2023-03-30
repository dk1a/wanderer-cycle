import { useMaps } from "../mud/hooks/useMaps";
import { useBossesDefeated } from "../mud/hooks/useBossesDefeated";
import { useWandererContext } from "../contexts/WandererContext";
import { useMemo } from "react";
import { useLifeCurrent } from "../mud/hooks/currents";
import BasicMap from "../components/Map/BasicMap";
import Map from "../components/Map";
import Party from "../components/Party";

export function GlobalMaps() {
  const { cycleEntity, party } = useWandererContext();

  const basicMaps = useMaps("Global Basic");
  const randomMaps = useMaps("Global Random");
  const bossMaps = useMaps("Global Cycle Boss");

  const bossesDefeated = useBossesDefeated(cycleEntity);
  const lifeCurrent = useLifeCurrent(cycleEntity);

  const bossMapsUndefeated = useMemo(() => {
    // show up to 3 undefeated bosses
    return bossMaps.filter(({ entity }) => !bossesDefeated.includes(entity)).slice(0, 3);
  }, [bossMaps, bossesDefeated]);

  return (
    <div className="flex flex-col">
      {!lifeCurrent && (
        <div className="text-dark-comment m-4">{"// you are out of life, passTurn fully restores life and mana"}</div>
      )}
      <div className="flex justify-around flex-wrap">
        <div className="flex flex-col mx-4">
          <h4 className="text-dark-comment">{"// Global Basic maps"}</h4>
          {basicMaps.map((data) => (
            <BasicMap key={data.entity} data={data} />
          ))}
        </div>
        <div>
          <h4 className="text-dark-comment">{"// Global Random maps"}</h4>
          <div className="flex flex-col gap-y-4 mr-4">
            {randomMaps.map((data) => (
              <Map key={data.entity} data={data} />
            ))}
          </div>
        </div>
        <div>
          <h4 className="text-dark-comment">{"// Global Boss maps"}</h4>
          <div className="flex flex-col gap-y-4 mr-4">
            {bossMapsUndefeated.map((data) => (
              <Map key={data.entity} data={data} />
            ))}
          </div>
        </div>
        {party && (
          <div className="flex flex-col">
            <Party header={"// party"} />
            <Party header={"// invite"} />
          </div>
        )}
      </div>
    </div>
  );
}
