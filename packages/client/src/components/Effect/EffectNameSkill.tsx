import { EntityIndex } from "@latticexyz/recs";
import { useSkill } from "../../mud/hooks/skill";

export default function EffectNameSkill({ entity }: { entity: EntityIndex }) {
  const { name } = useSkill(entity);

  return (
    <>
      <span className="text-dark-control mr-1">skill</span>
      <span className="text-dark-method" title={name}>
        {name}
      </span>
    </>
  );
}
