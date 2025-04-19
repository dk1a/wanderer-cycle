import { useCallback, useMemo, useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useStashCustom } from "../../mud/stash";
import { getCycleTurns } from "../../mud/utils/turns";
import { useMUD } from "../../MUDContext";
import { Button } from "../utils/Button/Button";

export default function PassTurnButton() {
  const { systemCalls } = useMUD();
  const { cycleEntity, enemyEntity } = useWandererContext();

  const turns = useStashCustom((state) => getCycleTurns(state, cycleEntity));

  const [isBusy, setIsBusy] = useState(false);

  const passTurn = useCallback(async () => {
    if (cycleEntity === undefined) throw new Error("No cycle entity");
    setIsBusy(true);
    await systemCalls.cycle.passTurn(cycleEntity);
    setIsBusy(false);
  }, [systemCalls, cycleEntity]);

  const isDisabled = useMemo(() => {
    // not available during combat (since it fully heals)
    const isEncounterActive = enemyEntity !== undefined;
    return !turns || isBusy || isEncounterActive;
  }, [turns, isBusy, enemyEntity]);

  return (
    <div className="ml-1">
      <Button
        onClick={passTurn}
        disabled={isDisabled}
        style={{ fontSize: "13px", border: "none", width: "" }}
      >
        {"passTurn"}
      </Button>
    </div>
  );
}
