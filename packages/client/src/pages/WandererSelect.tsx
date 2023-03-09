import { useWandererEntities } from "../mud/hooks/useWandererEntities";
import WandererSpawn from "../components/WandererSpawn";
import Wanderer from "../components/Wanderer";

export default function WandererSelect() {
  const wandererEntities = useWandererEntities();

  return (
    <div>
      {wandererEntities.length > 0 && (
        <section>
          <div className="flex justify-around">
            <div className="flex flex-col w-1/2 ml-5">
              <h3 className="m-10 text-2xl font-bold text-dark-comment text-center">{"// select a wanderer"}</h3>
              <div className="flex flex-wrap gap-x-4 gap-y-4 mt-2 justify-around">
                {wandererEntities.map((wandererEntity) => (
                  <Wanderer key={wandererEntity} wandererEntity={wandererEntity} />
                ))}
              </div>
            </div>
            <div className="flex flex-col w-1/2 mr-5">
              <h3 className=" mt-10 text-2xl font-bold text-dark-comment mb-10 text-center">
                {"// select a guise to spawn a new wanderer"}
              </h3>
              <WandererSpawn disabled={wandererEntities.length >= 3 ? true : false} />
            </div>
          </div>
        </section>
      )}
    </div>
  );
}
