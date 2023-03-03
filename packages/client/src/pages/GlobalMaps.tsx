import { useMaps } from "../mud/hooks/useMaps";
import BasicMap from "../components/Map/BasicMap";
import Map from "../components/Map";

export function GlobalMaps() {
  const basicMapEntities = useMaps("Global Basic");
  const randomMapEntities = useMaps("Global Random");

  return (
    <div className="flex justify-around flex-wrap">
      <div className="flex flex-col mx-20">
        {basicMapEntities.map((entity) => (
          <BasicMap key={entity} entity={entity} />
        ))}
      </div>
      <div className="">
        {randomMapEntities.map((entity) => (
          <Map key={entity} entity={entity} />
        ))}
      </div>
    </div>
  );
}
