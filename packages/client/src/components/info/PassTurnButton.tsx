import { useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";

export default function PassTurnButton() {
  const { selectedWandererEntity } = useWandererContext();

  // TODO add real encounter data
  const isEncounterActive = false;

  // TODO add availability data (cycle turns > 0)
  const isAvailable = true;

  const isWriterEnabled = !isEncounterActive;

  const [isBusy, setIsBusy] = useState(false);
  const passTurn = () => {
    setIsBusy(true);
    console.log("TODO add pass turn callback");
    setIsBusy(false);
  };

  return (
    <>
      {isAvailable &&
        {
          /* TODO replace with a working button+tooltip
      <TippyComment content="passTurn also restores life, mana">
        <MethodButton name="passTurn" className="col-span-3 text-start"
          disabled={isBusy}
          onClick={passTurn} />
      </TippyComment>
      */
        }}
    </>
  );
}
