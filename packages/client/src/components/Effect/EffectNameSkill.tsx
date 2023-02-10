import { EntityIndex } from "@latticexyz/recs";
import { useGuiseSkill } from "../../mud/hooks/useGuiseSkill";

export default function EffectNameSkill({ entity }: { entity: EntityIndex }) {
  const { name } = useGuiseSkill(entity);

  return (
    <>
      <span className="text-dark-control mr-1">skill</span>
      <span className="text-dark-type" title={name}>
        {name}
      </span>
    </>
  );
}
