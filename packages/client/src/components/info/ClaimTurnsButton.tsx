import { useCallback, useMemo, useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useMUD } from "../../mud/MUDContext";
import { EntityIndex } from "@latticexyz/recs";
import CustomButton from "../UI/CustomButton/CustomButton";

type ClaimTurnsButtonProps = {
  turns: number;
};

export default function ClaimTurnsButton({ turns }: ClaimTurnsButtonProps) {
  const { systems } = useMUD();
  const { selectedWandererEntity } = useWandererContext();
  // TODO add real claimable turns
  const claimableTurns = 10;

  const isAvailable = useMemo(() => {
    // TODO use proper availability
    return true;
  }, []);

  const isWriterEnabled = useMemo(() => {
    // TODO use proper availability
    return true;
  }, []);

  const [isBusy, setIsBusy] = useState(false);

  const claimTurns = useCallback(
    async (wandererEntity: EntityIndex) => {
      setIsBusy(true);
      const tx = await systems["system.ClaimCycleTurns"].executeTyped(wandererEntity);
      await tx.wait();
      setIsBusy(false);
    },
    [systems]
  );

  return (
    <>
      {isAvailable && (
        // TODO replace with a working CustomButton+tooltip
        <CustomButton args={[claimableTurns ?? ""]} disabled={isBusy} onClick={claimTurns} style={{ fontSize: "12px" }}>
          {"claimTurns"}
          <span className="text-dark-number">{` (${turns})`}</span>
        </CustomButton>
      )}
    </>
  );
}
