import { useMaps } from "../mud/hooks/useMaps";
import BasicMap from "../components/Map/BasicMap";
import Map from "../components/Map";

export function GlobalMaps() {
  const basicMapEntities = useMaps("Global Basic");
  const randomMapEntities = useMaps("Global Random");

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
        <div className="flex flex-col gap-y-4">
          {randomMapEntities.map((entity) => (
            <Map key={entity} entity={entity} />
          ))}
        </div>
      </div>
    </div>
  );
}
