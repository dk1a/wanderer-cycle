import { useCallback, useMemo, useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useExecuteCycleCombatRound } from "../../mud/hooks/combat";
import { attackAction } from "../../mud/utils/combat";
import { useSkills } from "../../mud/hooks/skill";
import CombatActions from "./CombatActions";
import { CombatRoundOutcome } from "./CombatRoundOutcome";
import Select from "react-select";
import "../UI/customSelect.scss";
import CustomButton from "../UI/Button/CustomButton";

export default function Combat() {
  const { selectedWandererEntity, lastCombatResult, learnedSkillEntities } = useWandererContext();
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
      <div className="flex justify-center w-1/2">
        <div className="text-2xl text-dark-type mr-2">selected map</div>
      </div>
      {lastCombatResult !== undefined && (
        <div className=" p-2 w-1/3 h-40 flex flex-col items-center mt-4">
          <CombatRoundOutcome lastCombatResult={lastCombatResult} />
          <CombatActions onAttack={onAttack} />
        </div>
      )}
      {lastCombatResult == undefined && (
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
              <CustomButton>use skill</CustomButton>
            </div>
          </div>
          <CombatActions onAttack={onAttack} />
        </div>
      )}
    </section>
  );
}
