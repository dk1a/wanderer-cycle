import { useCallback, useMemo, useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useExecuteCycleCombatRound } from "../../mud/hooks/combat";
import { attackAction } from "../../mud/utils/combat";
import CombatActions from "./CombatActions";
import { CombatRoundOutcome } from "./CombatRoundOutcome";
import Select from "react-select";
import "../UI/customSelect.scss";
import CustomButton from "../UI/Button/CustomButton";
import { useSkills } from "../../mud/hooks/skill";

export default function Combat() {
  const { selectedWandererEntity, lastCombatResult, learnedSkillEntities, cycleEntity } = useWandererContext();
  const executeCycleCombatRound = useExecuteCycleCombatRound();
  const skills = useSkills(learnedSkillEntities);

  const skillOptions = useMemo(() => skills.map(({ name, entity }) => ({ value: entity, label: name })), [skills]);
  const [selectedSkill, selectSkill] = useState<(typeof skillOptions)[number] | null>(null);

  const onAttack = useCallback(() => {
    if (!selectedWandererEntity) {
      throw new Error("Must select wanderer entity");
    }
    executeCycleCombatRound(selectedWandererEntity, [attackAction]);
  }, [selectedWandererEntity, executeCycleCombatRound]);

  console.log("skillOptions", skillOptions);
  // ========== RENDER ==========
  return (
    <section className="p-2 flex flex-col justify-center items-center w-full">
      {/* TODO re-enable after implementing rounds
      <div className="flex justify-center">
        <span className="text-dark-key text-xl">rounds: </span>
        <span className="m-0.5 ml-1 text-dark-number">{1}</span>
        <span className="m-0.5">/</span>
        <span className="m-0.5 text-dark-number">{MAX_ROUNDS}</span>
      </div>
      */}
      <div className="text-2xl text-dark-comment mr-2">{"// combat"}</div>
      {lastCombatResult !== undefined && <CombatRoundOutcome lastCombatResult={lastCombatResult} />}
      <div className="w-1/3">
        <div className="flex items-center justify-around">
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
            <CustomButton>use skill</CustomButton>
          </div>
        </div>
        <CombatActions onAttack={onAttack} />
      </div>
    </section>
  );
}
