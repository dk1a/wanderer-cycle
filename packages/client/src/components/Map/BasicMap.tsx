import { useWandererContext } from "../../contexts/WandererContext";
import { useActivateCycleCombat } from "../../mud/hooks/combat";
import { useCallback } from "react";
import { useActiveGuise } from "../../mud/hooks/guise";
import { useLevel } from "../../mud/hooks/charstat";
import CustomButton from "../UI/Button/CustomButton";
import { useCycleTurns } from "../../mud/hooks/turns";
import { LootData } from "../../mud/utils/getLoot";

export default function BasicMap({ data }: { data: LootData }) {
  const { selectedWandererEntity, cycleEntity } = useWandererContext();
  const activateCycleCombat = useActivateCycleCombat();

  const { entity, name, ilvl } = data;

  const guise = useActiveGuise(cycleEntity);
  const levelData = useLevel(cycleEntity, guise?.levelMul);
  const turns = useCycleTurns(cycleEntity);

  const onMapEnter = useCallback(() => {
    if (!selectedWandererEntity) {
      throw new Error("No selected wanderer entity");
    }
    activateCycleCombat(selectedWandererEntity, entity);
  }, [entity, selectedWandererEntity, activateCycleCombat]);

  const isHighLevel = levelData !== undefined && ilvl - levelData?.level > 2;

  return (
    <>
      <div className="grid grid-cols-3 bg-dark-500 w-48 py-2 px-1">
        <CustomButton className="col-span-2 mr-2" onClick={onMapEnter} disabled={!turns}>
          {name}
        </CustomButton>
        <span className="whitespace-nowrap">
          <span className="text-dark-key">level: </span>
          <span className={isHighLevel ? "text-red-400" : "text-dark-number"}>{ilvl}</span>
        </span>
      </div>
    </>
  );
}
