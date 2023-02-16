import { useWandererEntities } from "../mud/hooks/useWandererEntities";
import WandererSpawn from "../components/WandererSpawn";
import Wanderer from "../components/Wanderer";
import { useState } from "react";
import { useWandererContext } from "../contexts/WandererContext";

export default function WandererSelect() {
  const wandererEntities = useWandererEntities();
  const [activeWanderer, setActiveWanderer] = useState(false);
  const context = useWandererContext();
  console.log(context);

  const activeWandererHandler = () => {
    setActiveWanderer(!activeWanderer);
  };
  return (
    <div>
      {wandererEntities.length > 0 && (
        <section>
          <h3 className="m-10 text-2xl font-bold text-dark-comment">{"//select a wanderer"}</h3>
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
