import { useWandererContext } from "../../contexts/WandererContext";
import { useActivateCycleCombat } from "../../mud/hooks/combat";
import { useLoot } from "../../mud/hooks/useLoot";
import { useCallback } from "react";
import CustomButton from "../UI/Button/CustomButton";
import { EntityIndex } from "@latticexyz/recs";
import { useActiveGuise } from "../../mud/hooks/guise";
import { useLevel } from "../../mud/hooks/charstat";

export default function BasicMap({ entity }: { entity: EntityIndex }) {
  const { selectedWandererEntity, cycleEntity } = useWandererContext();
  const activateCycleCombat = useActivateCycleCombat();
  const loot = useLoot(entity);

  const guise = useActiveGuise(cycleEntity);
  const levelData = useLevel(cycleEntity, guise?.levelMul);

  const name = "map";
  const onMapEnter = useCallback(() => {
    if (!selectedWandererEntity) {
      throw new Error("No selected wanderer entity");
    }
    activateCycleCombat(selectedWandererEntity, entity);
  }, [entity, selectedWandererEntity, activateCycleCombat]);

  if (!loot) {
    return <div>TODO placeholder (this can happen while the hook is loading)</div>;
  }
  return (
    <>
      <div className="flex items-center">
        <div
          className="border border-dark-400 w-56 h-62 p-4 flex flex-col bg-dark-500 transform delay-500 m-4 cursor-pointer"
          onClick={onMapEnter}
        >
          <div className="flex justify-between items-center">
            <h3 className="text-xl text-dark-type text-center">{name}</h3>
            <span className="text-dark-key">
              {"ilvl: "}
              <span className={levelData?.level ? "text-red-500" : "text-dark-number"}>{loot?.ilvl}</span>
            </span>
          </div>
        </div>
        <div></div>
      </div>
    </>
  );
}
