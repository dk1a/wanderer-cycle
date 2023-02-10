import { useGuiseEntities } from "../../mud/hooks/useGuiseEntities";
import { useWandererSpawn } from "../../mud/hooks/useWandererSpawn";
import Guise from "../Guise/Guise";
import classes from "./wandererSpawn.module.scss";
// import * as querystring from "querystring";

export default function WandererSpawn() {
  const guiseEntities = useGuiseEntities();
  const wandererSpawn = useWandererSpawn();

  return (
    <div className={classes.wandererSpawn}>
      <h3 className={classes.header}>{"//select a Guise to Mint a New Wanderer"}</h3>
      {guiseEntities.map((guiseEntity) => (
        <div className={classes.guise__list} key={guiseEntity}>
          <Guise key={guiseEntity} entity={guiseEntity} onSelectGuise={wandererSpawn} />
        </div>
      ))}
    </div>
  );
}
