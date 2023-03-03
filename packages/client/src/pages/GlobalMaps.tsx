import { useMaps } from "../mud/hooks/useMaps";

export function GlobalMaps() {
  const basicMapEntities = useMaps("Global Basic");
  const randomMapEntities = useMaps("Global Random");

  return (
    <div className="flex justify-around flex-wrap h-full">
      {basicMapEntities.map((entity) => (
        <Map key={entity} entity={entity} />
      ))}
      {randomMapEntities.map((entity) => (
        <Map key={entity} entity={entity} />

      ))}
    </div>
  );
}
