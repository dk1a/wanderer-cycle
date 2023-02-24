import Map from "../components/Map";
import { useMaps } from "../mud/hooks/useMaps";
import { useWandererContext } from "../contexts/WandererContext";
import Combat from "../components/Combat";
import WandererSelect from "./WandererSelect";

const GlobalMaps = () => {
  const mapEntities = useMaps("Global Basic");
  const { selectedWandererEntity, enemyEntity } = useWandererContext();

  return (
    <>
      {selectedWandererEntity === undefined ? (
        <WandererSelect />
      ) : enemyEntity === undefined ? (
        <div className="flex justify-around flex-wrap">
          {mapEntities.map((entity) => (
            <Map key={entity} entity={entity} />
          ))}
        </div>
      ) : (
        <Combat />
      )}
    </>
  );
};

export default GlobalMaps;
