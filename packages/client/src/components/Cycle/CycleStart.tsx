import { useCallback, useMemo, useState } from "react";
import CustomSelect from "../UI/Select/CustomSelect";
import CustomButton from "../UI/Button/CustomButton";
import { useGuises } from "../../mud/hooks/guise";
import { EntityIndex } from "@latticexyz/recs";
import { useStartCycle } from "../../mud/hooks/cycle";
import { useLearnedSkillEntities, usePermSkill } from "../../mud/hooks/skill";
import SkillPermanent from "../Combat/SkillPermanent";
import Select from "react-select";

export function CycleStart({
  wandererEntity,
  previousCycleEntity,
}: {
  wandererEntity: EntityIndex;
  previousCycleEntity: EntityIndex;
}) {
  const startCycle = useStartCycle(wandererEntity);
  const learnedSkillEntities = useLearnedSkillEntities(previousCycleEntity);
  const onMakePermanent = usePermSkill(wandererEntity);
  const guises = useGuises();

  const [selectedGuiseEntity, selectGuiseEntity] = useState<string>();
  const [selectedWheelEntity, selectWheelEntity] = useState<number>();

  const wheel = [
    { value: "attainment", label: "Attainment" },
    { value: "isolation", label: "Isolation" },
  ];
  const guiseOptions = useMemo(() => guises.map(({ name, entity }) => ({ value: name, label: entity })), [guises]);

  const getValueGuise = useCallback(() => {
    return selectedGuiseEntity ? guiseOptions.find((i) => i.value === selectedGuiseEntity) : "";
  }, [selectedGuiseEntity]);

  const getValueWheel = useCallback(() => {
    return selectedWheelEntity ? guiseOptions.find((i) => i.label === selectedWheelEntity) : "";
  }, [selectedWheelEntity]);

  const onChangeGuise = useCallback(
    (newValue: any) => {
      selectGuiseEntity(newValue.value);
    },
    [selectGuiseEntity]
  );

  const onChangeWheel = useCallback(
    (newValue: string) => {
      selectWheelEntity(newValue.value);
    },
    [selectWheelEntity]
  );

  const onStart = useCallback(() => {
    if (selectedGuiseEntity === undefined) throw new Error("Invalid guise entity");
    if (selectedWheelEntity === undefined) throw new Error("Invalid wheel entity");
    startCycle(selectedGuiseEntity);
  }, [startCycle, selectedGuiseEntity, selectedWheelEntity]);

  console.log("guiseOptions", guiseOptions);
  return (
    <div className="flex w-full justify-around">
      <div className="flex mt-10">
        {learnedSkillEntities.map((entity) => (
          <div key={entity} className="flex flex-col items center">
            <SkillPermanent entity={entity} />
          </div>
        ))}
      </div>
      <div className="flex flex-col items-center mt-8">
        <span className="text-2xl text-dark-comment">{"// start"}</span>
        <div>
          <div className="flex w-96 mb-4">
            <span className="text-dark-string w-24">select a guise</span>
            <Select
              value={getValueGuise()}
              options={guiseOptions}
              placeholder={"select a guise"}
              onChange={onChangeGuise}
            />
          </div>
          <div className="flex w-96">
            <span className="text-dark-string w-24">select Wheel</span>
            <Select value={getValueWheel()} options={wheel} placeholder={"select a wheel"} onChange={onChangeWheel} />
          </div>
          <div className="flex flex-col items-center text-start mt-4">
            <span className="text-dark-string">Reward</span>
            <span className="text-dark-key">
              identity: <span className="text-dark-number">128</span>
            </span>
            <span className="text-dark-key">
              used:{" "}
              <span className="text-dark-number">
                0 <span className="text-dark-method">/</span> 4
              </span>
            </span>
          </div>
          <div className="flex items-center justify-center mt-4">
            <CustomButton
              onClick={onStart}
              disabled={selectedGuiseEntity === undefined || selectedWheelEntity === undefined}
            >
              start
            </CustomButton>
          </div>
        </div>
      </div>
    </div>
  );
}
