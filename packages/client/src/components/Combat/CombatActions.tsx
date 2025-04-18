import { useCallback, useMemo, useState } from "react";
import Select from "react-select";
import { Hex } from "viem";
import { useStashCustom } from "../../mud/stash";
import {
  CombatAction,
  CombatActionType,
  attackAction,
} from "../../mud/utils/combat";
import { getSkill, SkillType } from "../../mud/utils/skill";
import { useMUD } from "../../MUDContext";
import { useWandererContext } from "../../contexts/WandererContext";
import { UseSkillButton } from "../UseSkillButton";
import { Button } from "../utils/Button/Button";

export default function CombatActions() {
  const { systemCalls } = useMUD();
  const { cycleEntity, learnedSkillEntities } = useWandererContext();
  const [isBusy, setIsBusy] = useState(false);
  const [selectedSkill, selectSkill] = useState<{
    value: Hex;
    label: string;
  } | null>(null);

  const skills = useStashCustom((state) => {
    return learnedSkillEntities.map((entity) => getSkill(state, entity));
  });

  const combatSkills = useMemo(
    () => skills.filter(({ skillType }) => skillType === SkillType.COMBAT),
    [skills],
  );

  const skillOptions = useMemo(
    () =>
      combatSkills.map(({ name, entity }) => ({ value: entity, label: name })),
    [combatSkills],
  );

  const handleRound = useCallback(
    async (actions: CombatAction[]) => {
      if (!cycleEntity) {
        console.warn("No cycleEntity selected");
        return;
      }

      setIsBusy(true);
      try {
        await systemCalls.processCycleCombatRound(cycleEntity, actions);
      } catch (err) {
        console.error("Combat round failed", err);
      } finally {
        setIsBusy(false);
      }
    },
    [cycleEntity, systemCalls],
  );

  const onAttack = useCallback(async () => {
    await handleRound([attackAction]);
  }, [handleRound]);

  const onSkill = useCallback(async () => {
    if (!selectedSkill) {
      console.warn("No skill selected");
      return;
    }

    const fullSkill = combatSkills.find(
      (skill) => skill.entity === selectedSkill.value,
    );
    if (!fullSkill) {
      console.warn("Selected skill not found in combatSkills");
      return;
    }

    const skillAction: CombatAction = {
      actionType: CombatActionType.SKILL,
      actionEntity: fullSkill.entity,
    };

    await handleRound([skillAction]);
  }, [handleRound, selectedSkill, combatSkills]);

  return (
    <div className="flex flex-col items-center mt-4 w-full">
      <div className="flex flex-col items-center justify-around w-full">
        <div className="flex items-center justify-center gap-x-8 w-full">
          <div className="d-flex flex-col w-full">
            <Select
              classNamePrefix={"custom-select"}
              className={"w-full"}
              placeholder={"Select a skill"}
              options={skillOptions}
              onChange={selectSkill}
              value={selectedSkill}
            />
            {selectedSkill && (
              <div className="w-full mt-4">
                <UseSkillButton
                  entity={selectedSkill.value}
                  onSkill={onSkill}
                />
              </div>
            )}
          </div>
        </div>
      </div>
      <div className="mt-4">
        <Button style={{ width: "9rem" }} onClick={onAttack} disabled={isBusy}>
          Attack
        </Button>
      </div>
    </div>
  );
}
