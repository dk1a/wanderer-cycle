import { Wanderer } from "../../components/wanderer/Wanderer";
import { WandererSpawn } from "../../components/wanderer/WandererSpawn";
import { useStashCustom } from "../../mud/stash";
import { getWandererEntities } from "../../mud/utils/wanderer";

export function WandererSelect() {
  const wandererEntities = useStashCustom((state) =>
    getWandererEntities(state),
  );

  return (
    <div className="w-full h-full">
      <section className={"flex items-center justify-center"}>
        <div className="flex justify-around md:flex-row flex-col">
          {wandererEntities.length > 0 && (
            <div className="flex flex-col ml-2 p-4">
              <h3 className="mb-5 mt-5 text-2xl text-dark-comment">
                {"// select a wanderer"}
              </h3>
              <div className="flex flex-wrap gap-x-4 gap-y-4 justify-start">
                {wandererEntities.map((wandererEntity) => (
                  <Wanderer
                    key={wandererEntity}
                    wandererEntity={wandererEntity}
                  />
                ))}
              </div>
            </div>
          )}
          <div className="flex flex-col mr-2 p-4">
            <h3 className="mb-5 mt-5 text-2xl text-dark-comment">
              {"// select a guise to spawn a new wanderer"}
            </h3>
            <WandererSpawn
              disabled={wandererEntities.length >= 3 ? true : false}
            />
          </div>
        </div>
      </section>
    </div>
  );
}
