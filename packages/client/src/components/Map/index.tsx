import classes from "./map.module.scss";
import Effect from "../Effect";
import CustomButton from "../UI/CustomButton/CustomButton";
import { EntityIndex } from "@latticexyz/recs";
import { useLoot } from "../../mud/hooks/useLoot";
import { useWandererContext } from "../../contexts/WandererContext";
import { useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { useActiveCombat } from "../../mud/hooks/useActiveCombat";
import { useActivateCycleCombat } from "../../mud/hooks/useActivateCycleCombat";

interface MapProps {
  entity: EntityIndex;
}

const Map = ({ entity }: MapProps) => {
  const { selectedWandererEntity } = useWandererContext();
  const loot = useLoot(entity);
  const navigate = useNavigate();
  const name = loot.affixes[0].value;
  const activeCombat = useActiveCombat(entity);
  const activeCombatCycle = useActivateCycleCombat();

  const onMapEnter = useCallback(() => {
    if (!selectedWandererEntity) {
      throw new Error("Error");
    }
    activeCombatCycle(entity, selectedWandererEntity);
  }, [entity, selectedWandererEntity]);

  if (!loot) {
    return <div>TODO placeholder (this can happen while the hook is loading)</div>;
  }
  const effect = loot.effect;

  return (
    <div className={classes.map__container}>
      <h3 className={classes.map__header}>{name}</h3>
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
      {/*TODO use navigate,because onMapEnter outputs error*/}
      <CustomButton onClick={() => navigate(`combat/${entity}`)}>{"Enter"}</CustomButton>
    </div>
  );
};

export default Map;

// () => navigate(`combat/${entity}`)
