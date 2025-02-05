import { useCallback, useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useMUD } from "../../MUDContext";
import { Button } from "../utils/Button/Button";

export default function ClaimTurnsButton({
  claimableTurns,
}: {
  claimableTurns: number;
}) {
  const { systemCalls } = useMUD();
  const { selectedWandererEntity } = useWandererContext();

  const [isBusy, setIsBusy] = useState(false);
  const claimTurns = useCallback(async () => {
    if (!selectedWandererEntity) {
      throw new Error("No wanderer entity selected");
    }
    setIsBusy(true);
    await systemCalls.claimCycleTurns(selectedWandererEntity);
    setIsBusy(false);
  }, [systemCalls, selectedWandererEntity]);

  return (
    <div className="ml-1">
      <Button
        disabled={isBusy}
        onClick={claimTurns}
        style={{ fontSize: "13px", border: "none", width: "7rem" }}
      >
        {"claimTurns"}
        <span className="text-white">{" ("}</span>
        <span className="text-dark-number">{claimableTurns}</span>
        <span className="text-white">{")"}</span>
      </Button>
    </div>
  );
}
