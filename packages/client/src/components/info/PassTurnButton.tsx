import { useCallback, useMemo, useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useCycleTurns } from "../../mud/hooks/turns";
import { useMUD } from "../../mud/MUDContext";
import CustomButton from "../UI/Button/CustomButton";

export default function PassTurnButton() {
  const { world, systems } = useMUD();
  const { selectedWandererEntity, cycleEntity, enemyEntity } = useWandererContext();

  const turns = useCycleTurns(cycleEntity);

  const [isBusy, setIsBusy] = useState(false);
  const passTurn = useCallback(async () => {
    if (selectedWandererEntity === undefined) throw new Error("No wanderer selected");

    setIsBusy(true);
    const tx = await systems["system.PassCycleTurn"].executeTyped(world.entities[selectedWandererEntity]);
    await tx.wait();
    setIsBusy(false);
  }, [world, systems, selectedWandererEntity]);

  const isDisabled = useMemo(() => {
    // not available during combat (since it fully heals)
    const isEncounterActive = enemyEntity !== undefined;

    return !turns || isBusy || isEncounterActive;
  }, [turns, isBusy, enemyEntity]);

  return (
    <>
      {!!turns && (
        <CustomButton onClick={passTurn} disabled={isDisabled} style={{ fontSize: "12px", border: "none" }}>
          {"passTurn"}
        </CustomButton>
      )}
    </>
  );
}
