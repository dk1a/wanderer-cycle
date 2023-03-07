import CustomButton from "../UI/Button/CustomButton";
import { EntityIndex } from "@latticexyz/recs";
import { OnCompleteCycleData, useCompleteCycle, useOnCompleteCycleEffect } from "../../mud/hooks/cycle";
import { ReactNode, SetStateAction, useState } from "react";
import Modal from "../UI/Modal/Modal";

export function CycleEnd({ wandererEntity }: { wandererEntity: EntityIndex; cycleEntity: EntityIndex }) {
  const [active, setActive] = useState(false);
  const [identity, setIdentity] = useState();
  const CompleteCycle = useCompleteCycle(wandererEntity);

  useOnCompleteCycleEffect(wandererEntity, (identity) => {
    setIdentity({ identity });
    if (identity !== undefined) {
      setActive(true);
    }
  });

  return (
    <div className="flex flex-col items-center w-full">
      <div className="mt-10">
        <CustomButton onClick={() => CompleteCycle()}>Complete Cycle</CustomButton>
      </div>
      <Modal active={active} setActive={setActive}>
        <div className="text-dark-string text-lg">
          You gained
          <span className="text-dark-number mx-2">{identity}</span>
          identity
        </div>
      </Modal>
    </div>
  );
}
