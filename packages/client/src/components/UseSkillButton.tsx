import CustomButton from "./UI/Button/CustomButton";
import { useManaCurrent } from "../mud/hooks/currents";
import { useDuration } from "../mud/hooks/useDuration";
import { useWandererContext } from "../contexts/WandererContext";
import { useMemo } from "react";
import { EntityIndex } from "@latticexyz/recs";
import { useSkill } from "../mud/hooks/skill";

type UseSkillButtonData = {
  entity: EntityIndex | undefined;
  onSkill: () => Promise<void>;
  className?: string;
};
export function UseSkillButton({ entity, onSkill, className }: UseSkillButtonData) {
  const skill = useSkill(entity);
  const { cycleEntity } = useWandererContext();
  const manaCurrent = useManaCurrent(cycleEntity);
  const skillEntity = useMemo(() => skill?.entity, [skill]);
  const duration = useDuration(cycleEntity, skillEntity);

  return (
    <div className="flex">
      <CustomButton
        className={className}
        onClick={onSkill}
        disabled={
          skill === undefined ||
          manaCurrent === undefined ||
          manaCurrent <= skill.cost ||
          (duration !== undefined && duration.timeValue > 0)
        }
      >
        use skill
      </CustomButton>
      {duration !== undefined && duration.timeValue > 0 && (
        <div className="ml-2">
          <div className="text-dark-300">
            {"("}
            <span className="text-dark-number">{duration.timeValue} </span>
            <span className="text-dark-string">{duration.timeScopeName}</span>
            {")"}
          </div>
        </div>
      )}
    </div>
  );
}
