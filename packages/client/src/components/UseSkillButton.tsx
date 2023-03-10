import { SkillData, SkillType } from "../mud/utils/skill";
import CustomButton from "./UI/Button/CustomButton";
import { useManaCurrent } from "../mud/hooks/currents";
import { useDuration } from "../mud/hooks/useDuration";
import { useWandererContext } from "../contexts/WandererContext";
import { CSSProperties } from "react";
import { EntityIndex } from "@latticexyz/recs";
import { useSkill } from "../mud/hooks/skill";

type UseSkillButtonData = {
  entity: EntityIndex;
  isLearned?: boolean;
  onSkill: () => Promise<void>;
  style?: CSSProperties | undefined;
};
export default function UseSkillButton({ isLearned, onSkill, style, entity }: UseSkillButtonData) {
  const skill = useSkill(entity);
  const { cycleEntity } = useWandererContext();
  const manaCurrent = useManaCurrent(cycleEntity);
  const duration = useDuration(cycleEntity, skill.entity);

  const skillType = skill.skillType;

  return (
    <div>
      {isLearned && skillType === SkillType.NONCOMBAT && (
        <CustomButton
          style={style}
          onClick={onSkill}
          disabled={
            (manaCurrent !== undefined && manaCurrent <= skill.cost) ||
            (duration !== undefined && duration.timeValue < 0)
          }
        >
          use skill
        </CustomButton>
      )}
      {isLearned && duration !== undefined && (
        <div>
          {duration.timeValue > 0 && (
            <div>
              <span className="text-dark-key">{duration.timeScopeName}</span>
              <span className="text-dark-number">{duration.timeValue}</span>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
