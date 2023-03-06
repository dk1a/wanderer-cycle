import { useWandererContext } from "../../contexts/WandererContext";
import { useOnCompleteCycleEffect } from "../../mud/hooks/cycle";
import { CycleEnd } from "./CycleEnd";
import { CycleStart } from "./CycleStart";

export function Cycle() {
  const { selectedWandererEntity, cycleEntity, previousCycleEntity } = useWandererContext();
  useOnCompleteCycleEffect(selectedWandererEntity, (identity) => {
    console.log(`You gained ${identity} identity`);
  });

  return (
    <div className="flex justify-center w-full">
      {selectedWandererEntity !== undefined && cycleEntity === undefined && previousCycleEntity !== undefined && (
        <CycleStart wandererEntity={selectedWandererEntity} previousCycleEntity={previousCycleEntity} />
      )}
      {selectedWandererEntity !== undefined && cycleEntity !== undefined && (
        <CycleEnd wandererEntity={selectedWandererEntity} cycleEntity={cycleEntity} />
      )}
    </div>
  );
}
