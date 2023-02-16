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
    <div className="border border-dark-400 w-56 h-auto p-4 flex flex-col bg-dark-500 transform delay-500 m-4">
      <h3 className="text-xl text-dark-type text-center">{name}</h3>
      <hr className="h-px my-2 bg-dark-400 border-0" />
      <div className="text-dark-comment">
        {"//level: "}
        <span className="text-dark-number">{loot?.ilvl}</span>
      </div>
      <hr className="h-px my-2 bg-dark-400 border-0" />
      <div className="text-dark-comment">
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
      <hr className="h-px my-2 bg-dark-400 border-0" />
      {/*TODO use navigate,because onMapEnter outputs error*/}
      <CustomButton onClick={() => navigate(`combat/${entity}`)}>{"Enter"}</CustomButton>
    </div>
  );
};

export default Map;

// () => navigate(`combat/${entity}`)
