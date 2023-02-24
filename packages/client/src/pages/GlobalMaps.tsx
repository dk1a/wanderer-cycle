import Map from "../components/Map";
import { useMaps } from "../mud/hooks/useMaps";
import { useWandererContext } from "../contexts/WandererContext";
import Combat from "../components/Combat";
import Wanderer from "../components/Wanderer";
import { useWandererEntities } from "../mud/hooks/useWandererEntities";

const GlobalMaps = () => {
  const mapEntities = useMaps("Global Basic");
  const { selectedWandererEntity, enemyEntity } = useWandererContext();
  const wandererEntities = useWandererEntities();

  return (
    <>
      {selectedWandererEntity === undefined ? (
        <div>
          <h3 className="m-10 text-2xl font-bold text-dark-comment">{"// select a wanderer"}</h3>
          <div className="flex justify-around">
            <div className="flex flex-wrap gap-x-4 gap-y-4 mt-2 justify-around">
              {wandererEntities.map((wandererEntity) => (
                <Wanderer key={wandererEntity} wandererEntity={wandererEntity} />
              ))}
            </div>
          </div>
        </div>
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
