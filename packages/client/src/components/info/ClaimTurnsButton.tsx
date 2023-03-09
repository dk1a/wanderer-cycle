import { useCallback, useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useMUD } from "../../mud/MUDContext";
import CustomButton from "../UI/Button/CustomButton";

export default function ClaimTurnsButton({ claimableTurns }: { claimableTurns: number }) {
  const { world, systems } = useMUD();
  const { selectedWandererEntity } = useWandererContext();

  const [isBusy, setIsBusy] = useState(false);
  const claimTurns = useCallback(async () => {
    if (!selectedWandererEntity) {
      throw new Error("No wanderer entity selected");
    }
    setIsBusy(true);
    const tx = await systems["system.ClaimCycleTurns"].executeTyped(world.entities[selectedWandererEntity]);
    await tx.wait();
    setIsBusy(false);
  }, [world, systems, selectedWandererEntity]);

  return (
    <>
      <CustomButton disabled={isBusy} onClick={claimTurns} style={{ fontSize: "12px", border: "none" }}>
        {"claimTurns"}
        <span className="text-dark-number">{claimableTurns}</span>
      </CustomButton>
    </>
  );
}
