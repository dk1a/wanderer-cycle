import { useWandererEntities } from "../mud/hooks/useWandererEntities";
import WandererSpawn from "../components/WandererSpawn";
import classes from "../components/Wanderer/wanderer.module.scss";
import Wanderer from "../components/Wanderer";

export default function WandererSelect() {
  const wandererEntities = useWandererEntities();
  console.log(wandererEntities);
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
      <WandererSpawn />
    </div>
  );
}
