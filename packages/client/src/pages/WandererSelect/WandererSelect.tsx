import Wanderer from "../../components/Wanderer";
import WandererSpawn from "../../components/WandererSpawn";
import { useWandererEntities } from "../../mud/hooks/useWandererEntities";

interface WandererSelectProps {
  className?: string;
}

const WandererSelect = ({ className }: WandererSelectProps) => {
  const wandererEntities = useWandererEntities();

  return (
    <div className={className + " w-full h-full"}>
      <section className={"flex items-center justify-center"}>
        <div className="flex justify-around md:flex-row flex-col">
          {wandererEntities.length > 0 && (
            <div className="flex flex-col  ml-5 p-5">
              <h3 className="mb-5 mt-10 text-2xl font-bold text-dark-comment">
                {"// select a wanderer"}
              </h3>
              <div className="flex flex-wrap gap-x-4 gap-y-4 mt-2 justify-start">
                {wandererEntities.map((wandererEntity) => (
                  <Wanderer
                    key={wandererEntity}
                    wandererEntity={wandererEntity}
                  />
                ))}
              </div>
            </div>
          )}
          <div className="flex flex-col mr-5 p-5">
            <h3 className="mb-5 mt-5 text-2xl font-bold text-dark-comment">
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
};

export default WandererSelect;
