import { Fragment, useMemo } from "react";
import { useEffectPrototype } from "../mud/hooks/useEffectPrototype";
import { SkillType, useSkill } from "../mud/hooks/useSkill";
import { useStatmodPrototype } from "../mud/hooks/useStatmodPrototype";
import { EffectStatmodData } from "../mud/utils/effectStatmod";

export default function Skill({ skill }: { skill: ReturnType<typeof useSkill> }) {
  const effect = useEffectPrototype(skill.entity);

  return (
    <>
      <div className="bg-dark-500 border border-dark-400 p-2">
        <div className="text-dark-method text-xl">{skill.name}</div>
        <div className="text-dark-comment">{skill.description}</div>
        <div>
          <span className="text-dark-key">type: </span>
          <span className="text-dark-string">{skill.skillTypeName}</span>
        </div>
        {skill.skillType !== SkillType.PASSIVE && (
          <div>
            <span className="text-dark-key">cost: </span>
            <span className="text-dark-number">{skill.cost}</span>
            <span className="text-dark-string"> mana</span>
          </div>
        )}
        {skill.duration.timeValue > 0 && (
          <div>
            <span className="text-dark-key">duration: </span>
            <span className="text-dark-number">{skill.duration.timeValue}</span>
            <span className="text-dark-string"> {skill.duration.timeScopeName}</span>
          </div>
        )}
        {skill.cooldown.timeValue > 0 && (
          <div>
            <span className="text-dark-key">cooldown: </span>
            <span className="text-dark-number">{skill.cooldown.timeValue}</span>
            <span className="text-dark-string"> {skill.duration.timeScopeName}</span>
          </div>
        )}
      </div>

      {effect !== undefined && effect.statmods !== undefined && (
        <>
          <div className="">
            <span className="text-dark-key">effect target: </span>
            <span className="text-dark-string">{skill.skillTypeName}</span>
          </div>

          {effect.statmods.map((statmod) => (
            <SkillEffectStatmod key={statmod.protoEntity} statmod={statmod} />
          ))}
        </>
      )}
    </>
  );
}

function SkillEffectStatmod({ statmod }: { statmod: EffectStatmodData }) {
  const statmodPrototype = useStatmodPrototype(statmod.protoEntity);

  const nameParts = useMemo(() => {
    if (statmodPrototype === undefined) {
      return ["...", "..."];
    } else {
      return statmodPrototype.name.split("#");
    }
  }, [statmodPrototype]);

  return (
    <div className="text-dark-200">
      {nameParts.map((namePart, index) => (
        <Fragment key={namePart}>
          {index !== 0 && <span className="text-dark-number">{statmod.value}</span>}
          <span className="text-dark-string">{namePart}</span>
        </Fragment>
      ))}
    </div>
  );
}
