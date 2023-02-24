import { useCallback, useMemo, useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useMUD } from "../../mud/MUDContext";
import CustomButton from "../UI/Button/CustomButton";

export default function PassTurnButton() {
  const { world, systems } = useMUD();
  const { selectedWandererEntity } = useWandererContext();

  // TODO add real encounter data
  const isEncounterActive = false;

  // TODO add availability data (cycle turns > 0)
  const isAvailable = true;

  const [isBusy, setIsBusy] = useState(false);
  const passTurn = useCallback(async () => {
    if (selectedWandererEntity === undefined) throw new Error("No wanderer selected");

    setIsBusy(true);
    const tx = await systems["system.PassCycleTurn"].executeTyped(world.entities[selectedWandererEntity]);
    await tx.wait();
    setIsBusy(false);
  }, [world, systems, selectedWandererEntity]);

  const isDisabled = useMemo(() => isBusy || isEncounterActive, [isBusy, isEncounterActive]);

  return (
    <>
      {isAvailable && (
        <CustomButton onClick={passTurn} disabled={isDisabled} style={{ fontSize: "12px" }}>
          {"passTurn"}
        </CustomButton>
      )}
    </>
  );
}
