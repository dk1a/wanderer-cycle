import { useWandererEntities } from "../mud/hooks/useWandererEntities";
import WandererSpawn from "../components/WandererSpawn";
import Wanderer from "../components/Wanderer";

export default function WandererSelect() {
  const wandererEntities = useWandererEntities();

  return (
    <div>
      {wandererEntities.length > 0 && (
        <section>
          <h3 className="m-10 text-2xl font-bold text-dark-comment">{"// select a wanderer"}</h3>
          <div className="flex justify-around">
            <div className="flex flex-wrap gap-x-4 gap-y-4 mt-2 justify-around">
              {wandererEntities.map((wandererEntity) => (
                <Wanderer key={wandererEntity} wandererEntity={wandererEntity} />
              ))}
            </div>
          </div>
        </section>
      )}
      <WandererSpawn disabled={wandererEntities.length >= 3 ? true : false} />
    </div>
  );
}
