import Wanderer from "../../components/Wanderer";
import WandererSpawn from "../../components/WandererSpawn";
import { useWandererEntities } from "../../mud/hooks/useWandererEntities";

interface WandererSelectProps {
  className?: string;
}

const WandererSelect = ({ className }: WandererSelectProps) => {
  const wandererEntities = useWandererEntities();

  return (
    <div className={`${className} w-full h-full`}>
      <section>
        <div className="flex justify-around">
          {wandererEntities.length > 0 && (
            <div className="flex flex-col w-1/2 ml-5 p-10">
              <h3 className="mb-10 mt-10 text-2xl font-bold text-dark-comment">
                {"// select a wanderer"}
              </h3>
              <div className="flex flex-wrap gap-x-4 gap-y-4 mt-2 justify-around">
                {wandererEntities.map((wandererEntity) => (
                  <Wanderer
                    key={wandererEntity}
                    wandererEntity={wandererEntity}
                  />
                ))}
              </div>
            </div>
          )}
          <div className="flex flex-col w-1/2 mr-5 p-10">
            <h3 className="mb-10 mt-10 text-2xl font-bold text-dark-comment">
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
