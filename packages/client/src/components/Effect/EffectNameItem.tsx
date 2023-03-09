import { EntityIndex } from "@latticexyz/recs";
import { useLoot } from "../../mud/hooks/useLoot";

export default function EffectNameItem({ entity }: { entity: EntityIndex }) {
  const loot = useLoot(entity);

  return (
    <>
      <span className="text-dark-key mr-1">item</span>
      <span className="text-dark-method">{loot.name}</span>
    </>
  );
}
