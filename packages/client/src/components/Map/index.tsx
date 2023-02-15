import classes from "./map.module.scss";
import Effect from "../Effect";
import CustomButton from "../UI/CustomButton/CustomButton";
import { EntityIndex } from "@latticexyz/recs";
import { useLoot } from "../../mud/hooks/useLoot";
import { useWandererContext } from "../../contexts/WandererContext";
import { useCallback } from "react";
import { useNavigate } from "react-router-dom";

interface MapProps {
  entity: EntityIndex;
}

const Map = ({ entity }: MapProps) => {
  const { selectedWandererEntity } = useWandererContext();
  const loot = useLoot(entity);
  const navigate = useNavigate();
  console.log("navigate", navigate);
  // TODO compute name from affixes

  const onMapEnter = useCallback(() => {
    console.log(`TODO: enter combat using map entity ${entity} and wanderer ${selectedWandererEntity}`);
  }, [entity, selectedWandererEntity]);

  if (!loot) {
    return <div>TODO placeholder (this can happen while the hook is loading)</div>;
  }
  const effect = loot.effect;

  return (
    <div className={classes.map__container}>
      <h3 className={classes.map__header}>{loot.affixes[0].value}</h3>
      <hr className={classes.map__hr} />
      <div className={classes.map__description}>
        {"//level: "}
        <span className={classes.map__stats}>{loot?.ilvl}</span>
      </div>
      <hr className={classes.map__hr} />
      <div className={classes.map__description}>
        <span>{"//effect"}</span>
        <Effect
          entity={effect.entity}
          protoEntity={entity}
          removability={effect.removability}
          statmods={effect.statmods}
          isItem={true}
          isSkill={false}
        />
      </div>
      <hr className={classes.map__hr} />
      <CustomButton onClick={() => navigate(`${entity}`)}>{"Enter"}</CustomButton>
    </div>
  );
};

export default Map;
