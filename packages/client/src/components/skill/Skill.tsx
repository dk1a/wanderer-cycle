import { useStashCustom } from "../../mud/stash";
import { getEffectTemplate } from "../../mud/utils/getEffect";
import { SkillType, SkillData } from "../../mud/utils/skill";
import { EffectStatmods } from "../effect/EffectStatmods";

type SkillProps = {
  skill: SkillData;
  className?: string;
  isCollapsed?: boolean;
  onHeaderClick?: () => void;
};

export function Skill({
  skill,
  className,
  isCollapsed = false,
  onHeaderClick,
}: SkillProps) {
  const effect = useStashCustom((state) =>
    getEffectTemplate(state, skill.entity),
  );

  return (
    <div className={className}>
      <div
        onClick={onHeaderClick}
        className="flex justify-between cursor-pointer"
      >
        <span className="text-dark-method text-xl">{skill.name}</span>
        <div className="text-dark-key ml-2">
          requiredLevel:{" "}
          <span className="text-dark-number">{skill.requiredLevel}</span>
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
              {skill.templateDuration.timeValue > 0 && (
                <div className="flex">
                  <span className="text-dark-key mr-1">duration:</span>
                  <span className="text-dark-number mr-1">
                    {skill.templateDuration.timeValue}
                  </span>
                  <span className="text-dark-string">
                    {skill.templateDuration.timeId}
                  </span>
                </div>
              )}
              {skill.templateCooldown.timeValue > 0 && (
                <div className="flex">
                  <span className="text-dark-key mr-1">cooldown: </span>
                  <span className="text-dark-number mr-1">
                    {skill.templateCooldown.timeValue}
                  </span>
                  <span className="text-dark-string">
                    {skill.templateCooldown.timeId}
                  </span>
                </div>
              )}
              {effect !== undefined && effect.statmods !== undefined && (
                <div className="p-0.5 w-full mt-4">
                  <div className="text-dark-key">
                    targetType:{" "}
                    <span className="text-dark-string">
                      {skill.targetTypeName}
                    </span>
                  </div>
                  {effect.statmods && (
                    <EffectStatmods statmods={effect.statmods} />
                  )}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
