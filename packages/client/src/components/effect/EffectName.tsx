import { Hex } from "viem";
import { useStashCustom } from "../../mud/stash";
import { getLoot } from "../../mud/utils/getLoot";
import { getSkillName } from "../../mud/utils/skill";
import { EffectSource } from "../../mud/utils/getEffect";

export function EffectName({
  entity,
  effectSource,
}: {
  entity: Hex;
  effectSource: EffectSource;
}) {
  switch (effectSource) {
    case EffectSource.EQUIPMENT:
    case EffectSource.MAP:
      return <EffectNameLoot entity={entity} />;
    case EffectSource.SKILL:
      return <EffectNameSkill entity={entity} />;
    default:
      return <span>Unknown {entity}</span>;
  }
}

function EffectNameLoot({ entity }: { entity: Hex }) {
  const loot = useStashCustom((state) => getLoot(state, entity));

  return (
    <span className="text-sm text-dark-method" title={loot.name}>
      {loot.name}
    </span>
  );
}

function EffectNameSkill({ entity }: { entity: Hex }) {
  const skillName = useStashCustom((state) => getSkillName(state, entity));

  return (
    <span className="text-sm text-dark-method" title={skillName}>
      {skillName}
    </span>
  );
}
