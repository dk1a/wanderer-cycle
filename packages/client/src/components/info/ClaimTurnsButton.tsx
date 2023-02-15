import { useCallback, useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useMUD } from "../../mud/MUDContext";
import CustomButton from "../UI/CustomButton/CustomButton";

export default function ClaimTurnsButton() {
  const { systems } = useMUD();
  const { selectedWandererEntity } = useWandererContext();
  // TODO add real claimable turns
  const claimableTurns = 10;

  const [isBusy, setIsBusy] = useState(false);

  const claimTurns = useCallback(async () => {
    if (!selectedWandererEntity) {
      throw new Error("No wanderer entity selected");
    }
    setIsBusy(true);
    const tx = await systems["system.ClaimCycleTurns"].executeTyped(selectedWandererEntity);
    await tx.wait();
    setIsBusy(false);
  }, [systems, selectedWandererEntity]);

  return (
    <>
      <CustomButton disabled={isBusy} onClick={claimTurns} style={{ fontSize: "12px" }}>
        {"claimTurns"}
        <span className="text-dark-number">{` (${claimableTurns})`}</span>
      </CustomButton>
    </>
  );
}
