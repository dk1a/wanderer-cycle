import { EntityIndex } from "@latticexyz/recs";
import { useLoot } from "../../mud/hooks/useLoot";

export default function EffectNameItem({ entity }: { entity: EntityIndex }) {
  const loot = useLoot(entity);

  return (
    <>
      <span className="text-dark-method" title={loot.name}>
        {loot.name}
      </span>
    </>
  );
}
