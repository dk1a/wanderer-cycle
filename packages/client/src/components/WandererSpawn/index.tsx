import { useGuiseEntities } from "../../mud/hooks/useGuiseEntities";
import { useWandererSpawn } from "../../mud/hooks/useWandererSpawn";
import Guise from "../Guise/Guise";
import classes from "./wandererSpawn.module.scss";

export default function WandererSpawn({ disabled }: boolean) {
  const guiseEntities = useGuiseEntities();
  const wandererSpawn = useWandererSpawn();

  return (
    <div className={classes.wandererSpawn}>
      <h3 className={classes.header}>{"//select a Guise to Mint a New Wanderer"}</h3>
      {guiseEntities.map((guiseEntity) => (
        <div className={classes.guise__list} key={guiseEntity}>
          <Guise key={guiseEntity} entity={guiseEntity} onSelectGuise={wandererSpawn} disabled={disabled} />
        </div>
      ))}
    </div>
  );
}
