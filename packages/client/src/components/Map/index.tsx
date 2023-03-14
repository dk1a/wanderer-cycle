import Effect from "../Effect";
import CustomButton from "../UI/Button/CustomButton";
import { useWandererContext } from "../../contexts/WandererContext";
import { useCallback } from "react";
import { EffectSource } from "../../mud/utils/getEffect";
import { useActivateCycleCombat } from "../../mud/hooks/combat";
import { useCycleTurns } from "../../mud/hooks/turns";
import { LootData } from "../../mud/utils/getLoot";

export default function Map({ data }: { data: LootData }) {
  const { selectedWandererEntity, cycleEntity } = useWandererContext();
  const activateCycleCombat = useActivateCycleCombat();

  const { entity, name, ilvl, effect } = data;

  const turns = useCycleTurns(cycleEntity);

  const onMapEnter = useCallback(() => {
    if (!selectedWandererEntity) {
      throw new Error("No selected wanderer entity");
    }
    activateCycleCombat(selectedWandererEntity, entity);
  }, [entity, selectedWandererEntity, activateCycleCombat]);

  return (
    <div className="border border-dark-400 w-56 h-62 p-4 flex flex-col bg-dark-500">
      <CustomButton onClick={onMapEnter} disabled={!turns}>
        {name}
      </CustomButton>
      <div className="text-dark-comment mt-1">
        <span className="text-dark-key">level: </span>
        <span className="text-dark-number">{ilvl}</span>
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
