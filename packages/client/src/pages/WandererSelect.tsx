import { useWandererEntities } from "../mud/hooks/useWandererEntities";
import WandererSpawn from "../components/WandererSpawn";
import classes from "../components/Wanderer/wanderer.module.scss";
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
          <h3 className={classes.header}>{"//select a wanderer"}</h3>
          <div className={classes.wanderer__parent}>
            <div className={classes.wanderer__container}>
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
