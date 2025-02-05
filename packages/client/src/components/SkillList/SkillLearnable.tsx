import { Entity } from "@latticexyz/recs";
import { useCallback, useMemo, useState } from "react";
// import { SkillType } from "../../mud/utils/skill";

import { useWandererContext } from "../../contexts/WandererContext";
import { useSkillStrict } from "../../mud/hooks/skill";
import { Button } from "../utils/Button/Button";
// import {useLevel} from "..useLevel/../mud/hooks/charstat";
import Skill from "../Guise/Skill";

export default function SkillLearnable({
  entity,
  withButtons,
}: {
  entity: Entity;
  withButtons: boolean;
}) {
  const {
    learnCycleSkill,
    learnedSkillEntities,
    // cycleEntity,
  } = useWandererContext();
  const skill = useSkillStrict(entity);
  // const duration = useDuration(cycleEntity, skill.entity);

  // const guise = useActiveGuise(cycleEntity);
  // const level = useLevel(cycleEntity, guise?.levelMul)?.level;

  // const executeNoncombatSkill = useExecuteNoncombatSkill();
  // const onSkill = useCallback(async () => {
  //   if (!cycleEntity) throw new Error("Cycle must be active");
  //   await executeNoncombatSkill(cycleEntity, skill.entity);
  // }, [cycleEntity, executeNoncombatSkill, skill]);

  const isLearned = useMemo(
    () => learnedSkillEntities.includes(entity),
    [learnedSkillEntities, entity],
  );

  const [visible, setVisible] = useState(!isLearned);

  const onHeaderClick = useCallback(() => {
    // only expand collapsed data
    if (!visible) {
      setVisible(true);
    }
  }, [visible]);

  return (
    <div className="p-0 flex mb-8 items-center">
      <Skill
        skill={skill}
        className={`bg-dark-500 border border-dark-400 p-2 w-[400px]`}
        isCollapsed={!visible}
        onHeaderClick={onHeaderClick}
      />
      {withButtons && (
        <div className="h-1/2 ml-10">
          {!isLearned && (
            <Button
              onClick={() => learnCycleSkill(entity)}
              // disabled={level !== undefined && level < skill.requiredLevel}
            >
              learn
            </Button>
          )}
          {/*{isLearned && skill.skillType === SkillType.COMBAT && <UseSkillButton entity={entity} onSkill={onSkill} />}*/}
        </div>
      )}
    </div>
  );
}
