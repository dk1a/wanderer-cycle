import { useWandererContext } from "../../contexts/WandererContext";
import { useActivateCycleCombat } from "../../mud/hooks/combat";
import { useLoot } from "../../mud/hooks/useLoot";
import { useCallback } from "react";
import { EntityIndex } from "@latticexyz/recs";
import { useActiveGuise } from "../../mud/hooks/guise";
import { useLevel } from "../../mud/hooks/charstat";
import CustomButton from "../UI/Button/CustomButton";
import { useCycleTurns, useCycleTurnsLastClaimedComponent } from "../../mud/hooks/useCycleTurns";

export default function BasicMap({ entity }: { entity: EntityIndex }) {
  const { selectedWandererEntity, cycleEntity } = useWandererContext();
  const activateCycleCombat = useActivateCycleCombat();
  const loot = useLoot(entity);

  const guise = useActiveGuise(cycleEntity);
  const levelData = useLevel(cycleEntity, guise?.levelMul);
  const turns = useCycleTurns(cycleEntity);
  const turnsLast = useCycleTurnsLastClaimedComponent(cycleEntity);

  console.log("turnsLast", turnsLast);

  const onMapEnter = useCallback(() => {
    if (!selectedWandererEntity) {
      throw new Error("No selected wanderer entity");
    }
    activateCycleCombat(selectedWandererEntity, entity);
  }, [entity, selectedWandererEntity, activateCycleCombat]);

  if (!loot) {
    return <div>TODO placeholder (this can happen while the hook is loading)</div>;
  }

  const name = loot.name;
  const isHighLevel = levelData !== undefined && loot.ilvl - levelData?.level > 2;

  return (
    <>
      <div className="grid grid-cols-3 bg-dark-500 w-48 py-2 px-1">
        <CustomButton className="col-span-2 mr-2" onClick={onMapEnter} disabled={!turns}>
          {name}
        </CustomButton>
        <span className="whitespace-nowrap">
          <span className="text-dark-key">level: </span>
          <span className={isHighLevel ? "text-red-400" : "text-dark-number"}>{loot.ilvl}</span>
        </span>
      </div>
    </>
  );
}
