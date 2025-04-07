import { useMemo } from "react";
import { Hex } from "viem";
import { useStashCustom } from "../../mud/stash";
import { useWandererContext } from "../../contexts/WandererContext";
import { getBossesDefeated } from "../../mud/utils/getBossesDefeated";
import { getMaps, MapTypes } from "../../mud/utils/getMaps";
import { getLifeCurrent } from "../../mud/utils/currents";
import BasicMap from "../../components/Map/BasicMap";
import Map from "../../components/Map";

const GlobalMapsPage = () => {
  const { cycleEntity } = useWandererContext();

  const basicMaps = useStashCustom((state) =>
    getMaps(state, MapTypes["Basic"]),
  );
  const randomMaps = useStashCustom((state) =>
    getMaps(state, MapTypes["Random"]),
  );
  const bossMaps = useStashCustom((state) =>
    getMaps(state, MapTypes["Cycle Boss"]),
  );

  const bossesDefeated = useStashCustom((state) =>
    getBossesDefeated(state, cycleEntity as Hex),
  );
  const lifeCurrent = useStashCustom((state) =>
    getLifeCurrent(state, cycleEntity),
  );

  const bossMapsUndefeated = useMemo(() => {
    // show up to 3 undefeated bosses
    return bossMaps
      .filter(({ entity }) => !bossesDefeated.includes(entity))
      .slice(0, 3);
  }, [bossMaps, bossesDefeated]);

  return (
    <div className="flex flex-col">
      {!lifeCurrent && (
        <div className="text-dark-comment m-4">
          {"// you are out of life, passTurn fully restores life and mana"}
        </div>
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
      </div>
    </div>
  );
};

export default GlobalMapsPage;
