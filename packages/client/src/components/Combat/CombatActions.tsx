import { useCallback, useMemo, useState } from "react";
import Select from "react-select";
import { useWandererContext } from "../../contexts/WandererContext";
import { useExecuteCycleCombatRound } from "../../mud/hooks/combat";
import { useSkills } from "../../mud/hooks/skill";
import { useMUD } from "../../mud/MUDContext";
import { ActionType, attackAction, CombatAction } from "../../mud/utils/combat";
import { SkillType } from "../../mud/utils/skill";
import CustomButton from "../UI/Button/CustomButton";
import "../UI/customSelect.scss";
import UseSkillButton from "../UseSkillButton";

export default function CombatActions() {
  const { world } = useMUD();
  const { selectedWandererEntity, learnedSkillEntities } = useWandererContext();
  const [isBusy, setIsBusy] = useState(false);

  // attack
  const executeCycleCombatRound = useExecuteCycleCombatRound();
  const onAttack = useCallback(async () => {
    if (!selectedWandererEntity) throw new Error("Must select wanderer entity");
    setIsBusy(true);
    await executeCycleCombatRound(selectedWandererEntity, [attackAction]);
    setIsBusy(false);
  }, [selectedWandererEntity, executeCycleCombatRound]);

  // skill list
  const skills = useSkills(learnedSkillEntities);
  const combatSkills = useMemo(() => skills.filter(({ skillType }) => skillType === SkillType.COMBAT), [skills]);
  const skillOptions = useMemo(
    () => combatSkills.map(({ name, entity }) => ({ value: entity, label: name })),
    [combatSkills]
  );
  const [selectedSkill, selectSkill] = useState<(typeof skillOptions)[number] | null>(null);
  // skill use callback
  const onSkill = useCallback(async () => {
    if (!selectedWandererEntity) throw new Error("Must select wanderer entity");
    if (selectedSkill === null) throw new Error("No skill selected");
    setIsBusy(true);
    const skillEntityId = world.entities[selectedSkill.value];
    const skillAction: CombatAction = {
      actionType: ActionType.SKILL,
      actionEntity: skillEntityId,
    };
    await executeCycleCombatRound(selectedWandererEntity, [skillAction]);
    setIsBusy(false);
  }, [world, selectedWandererEntity, executeCycleCombatRound, selectedSkill]);

  return (
    <div className="w-1/2 flex flex-col items-center mt-4">
      <div className="flex flex-col items-center justify-around w-full">
        <div className="flex items-center justify-around w-full">
          <Select
            classNamePrefix={"custom-select"}
            placeholder={"select a skill"}
            value={selectedSkill}
            options={skillOptions}
            onChange={selectSkill}
          />
          <UseSkillButton entity={selectedSkill?.value} onSkill={onSkill} style={{ width: "9rem" }} />
        </div>
      </div>
      <div className="mt-4">
        <CustomButton style={{ width: "9rem" }} onClick={onAttack} disabled={isBusy}>
          attack
        </CustomButton>
      </div>
    </div>
  );
}
