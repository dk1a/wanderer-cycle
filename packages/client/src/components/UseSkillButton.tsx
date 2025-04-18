import { CSSProperties } from "react";
import { Hex } from "viem";
import { useStashCustom } from "../mud/stash";
import { getSkill } from "../mud/utils/skill";
import { getManaCurrent } from "../mud/utils/currents";
import { formatZeroTerminatedString } from "../mud/utils/format";
import { Button } from "./utils/Button/Button";

type UseSkillButtonData = {
  entity: Hex;
  onSkill: () => Promise<void>;
  style?: CSSProperties;
};

export function UseSkillButton({ entity, onSkill, style }: UseSkillButtonData) {
  const skill = useStashCustom((state) => getSkill(state, entity));
  const manaCurrent = useStashCustom((state) => getManaCurrent(state, entity));

  return (
    <div className="flex items-center justify-center">
      <Button
        style={style}
        onClick={onSkill}
        disabled={
          skill === undefined ||
          manaCurrent === undefined ||
          manaCurrent <= skill.cost ||
          (skill.duration !== undefined && skill.duration.timeValue > 0)
        }
      >
        use skill
      </Button>
      {skill.duration !== undefined && skill.duration.timeValue > 0 && (
        <div className="ml-2">
          <div className="text-dark-300">
            {"( "}
            <span className="text-dark-number">{skill.duration.timeValue}</span>
            {
              <span className="text-dark-string">
                {formatZeroTerminatedString(skill.duration.timeId)}
              </span>
            }
            {" )"}
          </div>
        </div>
      )}
    </div>
  );
}
