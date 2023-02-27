import { Fragment, useMemo } from "react";
import { useEffectPrototype } from "../mud/hooks/useEffectPrototype";
import { useStatmodPrototype } from "../mud/hooks/useStatmodPrototype";
import { EffectStatmodData } from "../mud/utils/effectStatmod";
import { SkillData, SkillType } from "../mud/utils/skill";

type SkillProps = {
  skill: SkillData;
  className: string;
  isCollapsed?: boolean;
  onHeaderClick?: () => void;
};

export default function Skill({ skill, className, isCollapsed = false, onHeaderClick }: SkillProps) {
  const effect = useEffectPrototype(skill.entity);

  return (
    <div className={className}>
      <div onClick={onHeaderClick} className={"text-dark-method text-xl flex justify-between cursor-pointer"}>
        {skill.name}
        <div className="text-dark-key ml-2 text-[16px]">
          required level: <span className="text-dark-string">{skill.requiredLevel}</span>
        </div>
      </div>
      {!isCollapsed && (
        <div>
          <div className="text-dark-comment">{`// ${skill.description}`}</div>
          <div className="flex justify-between">
            <div className="w-full">
              <div>
                <span className="text-dark-key">type: </span>
                <span className="text-dark-string">{skill.skillTypeName}</span>
              </div>
              {skill.skillType !== SkillType.PASSIVE && (
                <div>
                  <span className="text-dark-key">cost: </span>
                  <span className="text-dark-number mr-1">{skill.cost}</span>
                  <span className="text-dark-string">mana</span>
                </div>
              )}
              {skill.duration.timeValue > 0 && (
                <div className="flex">
                  <span className="text-dark-key mr-1">duration:</span>
                  <span className="text-dark-number mr-1">{skill.duration.timeValue}</span>
                  <span className="text-dark-string"> {skill.duration.timeScopeName}</span>
                </div>
              )}
              {skill.cooldown.timeValue > 0 && (
                <div className="flex">
                  <span className="text-dark-key mr-1">cooldown: </span>
                  <span className="text-dark-number mr-1">{skill.cooldown.timeValue}</span>
                  <span className="text-dark-string"> {skill.duration.timeScopeName}</span>
                </div>
              )}
              <div className="p-0.5 w-full mt-4">
                {effect !== undefined && effect.statmods !== undefined && (
                  <>
                    <div className="">
                      <span className="text-dark-key">
                        effect target: <span className="text-dark-number">{skill.effectTargetName}</span>{" "}
                      </span>
                      <span className="text-dark-string">{skill.skillTypeName}</span>
                    </div>
                    {effect.statmods.map((statmod) => (
                      <SkillEffectStatmod key={statmod.protoEntity} statmod={statmod} />
                    ))}
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
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
