import { EntityIndex } from "@latticexyz/recs";
import { useLoot } from "../../mud/hooks/useLoot";
import { EffectModifier } from "../Effect/EffectStatmod";

const InventoryEquipment = ({ entity }: { entity: EntityIndex }) => {
  const loot = useLoot(entity);
  // TODO these should be parsed together
  const statmods = loot?.effect.statmods;
  const affixes = loot?.affixes;

  return (
    <div className="flex items-center justify-center flex-wrap w-1/2">
      <div className="text-dark-key p-2 flex flex-col border border-dark-400 w-72">
        <span className="text-xl text-dark-type flex-wrap flex">{loot?.name}</span>
        {statmods &&
          affixes &&
          statmods.map(({ protoEntity, value }, index) => (
            <EffectModifier key={`${affixes[index].partId}${protoEntity}`} protoEntity={protoEntity} value={value} />
          ))}
      </div>
    </div>
  );
};

export default InventoryEquipment;
