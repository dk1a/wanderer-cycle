import { useCallback, useState } from "react";
import { useWandererContext } from "../../mud/WandererProvider";
import { useSystemCalls } from "../../mud/SystemCallsProvider";
import { Button } from "../ui/Button";

export function ClaimTurnsButton({
  claimableTurns,
}: {
  claimableTurns: number;
}) {
  const systemCalls = useSystemCalls();
  const { cycleEntity } = useWandererContext();

  const [isBusy, setIsBusy] = useState(false);
  const claimTurns = useCallback(async () => {
    if (!cycleEntity) {
      throw new Error("No cycle entity selected");
    }
    setIsBusy(true);
    await systemCalls.cycle.claimTurns(cycleEntity);
    setIsBusy(false);
  }, [systemCalls, cycleEntity]);

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
