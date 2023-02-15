import Map from "../components/Map";
import { useMaps } from "../mud/hooks/useMaps";
import { useWandererContext } from "../contexts/WandererContext";
import WandererSelect from "./WandererSelect";

const GlobalMaps = () => {
  const mapEntities = useMaps("Global Basic");
  const { selectedWandererEntity } = useWandererContext();

  return (
    <>
      {selectedWandererEntity === undefined ? (
        <WandererSelect />
      ) : (
        <div className="flex justify-around flex-wrap">
          {mapEntities.map((entity) => (
            <Map key={entity} entity={entity} />
          ))}
        </div>
      )}
    </>
  );
};

export default GlobalMaps;
