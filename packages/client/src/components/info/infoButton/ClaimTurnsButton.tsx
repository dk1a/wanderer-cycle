import { useCallback, useMemo, useState } from "react";
import { useWandererContext } from "../../../contexts/WandererContext";
import { useMUD } from "../../../mud/MUDContext";
import { EntityIndex } from "@latticexyz/recs";

export default function ClaimTurnsButton() {
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
      {isAvailable &&
        // TODO replace with a working button+tooltip
        {
          /*<TippyComment content="claimTurns also seeds encounters">
        <MethodButton name="claimTurns" className="col-span-3 text-start"
          args={[claimableTurns ?? '']}
          disabled={isBusy}
          onClick={claimTurns} />
      </TippyComment>
      */
        }}
    </>
  );
}
