import CustomButton from "../UI/Button/CustomButton";
import { EntityIndex } from "@latticexyz/recs";
import { useCompleteCycle } from "../../mud/hooks/cycle";

export function CycleEnd({ wandererEntity }: { wandererEntity: EntityIndex; cycleEntity: EntityIndex }) {
  const completeCycle = useCompleteCycle(wandererEntity);
  return (
    <div className="flex flex-col items-center w-full">
      <div>
        <CustomButton onClick={() => completeCycle()}>Complete Cycle</CustomButton>
      </div>
    </div>
  );
}
