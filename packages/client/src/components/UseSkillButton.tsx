import CustomButton from "./UI/Button/CustomButton";
import { useManaCurrent } from "../mud/hooks/currents";
import { useDuration } from "../mud/hooks/useDuration";
import { useWandererContext } from "../contexts/WandererContext";
import { CSSProperties } from "react";
import { EntityIndex } from "@latticexyz/recs";
import { useSkill } from "../mud/hooks/skill";

type UseSkillButtonData = {
  entity: EntityIndex | undefined;
  onSkill: () => Promise<void>;
  style?: CSSProperties;
};
export default function UseSkillButton({ entity, onSkill, style }: UseSkillButtonData) {
  const skill = useSkill(entity);
  const { cycleEntity } = useWandererContext();
  const manaCurrent = useManaCurrent(cycleEntity);
  const duration = useDuration(cycleEntity, skill?.entity);

  return (
    <div>
      <CustomButton
        style={style}
        onClick={onSkill}
        disabled={
          skill === undefined ||
          manaCurrent === undefined ||
          manaCurrent <= skill.cost ||
          (duration !== undefined && duration.timeValue < 0)
        }
      >
        use skill
      </CustomButton>
      {duration !== undefined && (
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
