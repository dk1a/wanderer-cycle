import { useCallback, useMemo, useState } from "react";
import Select from "react-select";
import { useWandererContext } from "../../contexts/WandererContext";
import { useExecuteCycleCombatRound } from "../../mud/hooks/combat";
import { useSkills } from "../../mud/hooks/skill";
import { attackAction } from "../../mud/utils/combat";
import { SkillType } from "../../mud/utils/skill";
import CustomButton from "../UI/Button/CustomButton";
import "../UI/customSelect.scss";

export default function CombatActions() {
  const { selectedWandererEntity, learnedSkillEntities } = useWandererContext();
  const [isBusy, setIsBusy] = useState(false);

  const executeCycleCombatRound = useExecuteCycleCombatRound();
  const onAttack = useCallback(async () => {
    if (!selectedWandererEntity) throw new Error("Must select wanderer entity");
    setIsBusy(true);
    await executeCycleCombatRound(selectedWandererEntity, [attackAction]);
    setIsBusy(false);
  }, [selectedWandererEntity, executeCycleCombatRound]);

  const skills = useSkills(learnedSkillEntities);
  const combatSkills = useMemo(() => skills.filter(({ skillType }) => skillType === SkillType.COMBAT), [skills]);
  const skillOptions = useMemo(
    () => combatSkills.map(({ name, entity }) => ({ value: entity, label: name })),
    [combatSkills]
  );
  const [selectedSkill, selectSkill] = useState<(typeof skillOptions)[number] | null>(null);
  const onSkill = useCallback(() => {
    if (!selectedWandererEntity) throw new Error("Must select wanderer entity");
    setIsBusy(true);
    console.log("TODO onSkill");
    setIsBusy(false);
  }, [selectedWandererEntity]);

  return (
    <div className="w-1/2 flex flex-col items-center mt-4">
      <div className="flex items-center justify-around w-full">
        <div>
          <Select
            classNamePrefix={"custom-select"}
            placeholder={"select a skill"}
            value={selectedSkill}
            options={skillOptions}
            onChange={selectSkill}
          />
        </div>
        <div className="h-1/2">
          <CustomButton onClick={onSkill} disabled={isBusy}>
            use skill
          </CustomButton>
        </div>
      </div>
      <CustomButton onClick={onAttack} disabled={isBusy}>
        attack
      </CustomButton>
    </div>
  );
}
