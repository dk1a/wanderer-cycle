import { useCallback } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useExecuteCycleCombatRound } from "../../mud/hooks/combat";
import { useSkills } from "../../mud/hooks/skill";
import { attackAction } from "../../mud/utils/combat";
import CustomButton from "../UI/Button/CustomButton";

export default function CombatActions() {
  const { selectedWandererEntity, learnedSkillEntities } = useWandererContext();
  const executeCycleCombatRound = useExecuteCycleCombatRound();
  const learnedSkills = useSkills(learnedSkillEntities);

  const onAttack = useCallback(() => {
    if (!selectedWandererEntity) {
      throw new Error("Must select wanderer entity");
    }
    executeCycleCombatRound(selectedWandererEntity, [attackAction]);
  }, [selectedWandererEntity, executeCycleCombatRound]);
  return (
    <>
      <div className="flex-default justify-center mt-8">
        <CustomButton onClick={onAttack}>attack</CustomButton>
      </div>
    </>
  );
}
