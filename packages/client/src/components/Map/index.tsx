import Effect from "../Effect";
import CustomButton from "../UI/Button/CustomButton";
import { EntityIndex } from "@latticexyz/recs";
import { useLoot } from "../../mud/hooks/useLoot";
import { useWandererContext } from "../../contexts/WandererContext";
import { useCallback } from "react";
import { EffectSource } from "../../mud/utils/getEffect";
import { useActivateCycleCombat } from "../../mud/hooks/combat";
import { useCycleTurns } from "../../mud/hooks/useCycleTurns";

export default function Map({ entity }: { entity: EntityIndex }) {
  const { selectedWandererEntity, cycleEntity } = useWandererContext();
  const activateCycleCombat = useActivateCycleCombat();
  const loot = useLoot(entity);

  const turns = useCycleTurns(cycleEntity);

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
  const effect = loot.effect;

  return (
    <div className="border border-dark-400 w-56 h-62 p-4 flex flex-col bg-dark-500">
      <CustomButton onClick={onMapEnter} disabled={!turns}>
        {name}
      </CustomButton>
      <div className="text-dark-comment mt-1">
        <span className="text-dark-key">level: </span>
        <span className="text-dark-number">{loot?.ilvl}</span>
      </div>
      <div className="text-dark-comment">
        <Effect
          entity={effect.entity}
          protoEntity={entity}
          removability={effect.removability}
          statmods={effect.statmods}
          effectSource={EffectSource.MAP}
        />
      </div>
    </div>
  );
}
