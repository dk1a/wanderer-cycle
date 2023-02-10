import { useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import CustomButton from "../UI/CustomButton/CustomButton";

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
      {isAvailable && (
        // TODO replace with a working CustomButton+tooltip
        <CustomButton onClick={passTurn} style={{ fontSize: "14px" }}>
          {"passTurn"}
        </CustomButton>
      )}
    </>
  );
}
