import { useWandererContext } from "../../contexts/WandererContext";
import CombatActions from "./CombatActions";
import { CombatRoundOutcome } from "./CombatRoundOutcome";
import { useState } from "react";
import CustomButton from "../UI/Button/CustomButton";
import CombatTab from "./CombatTab";

export function Combat() {
  const { lastCombatResult } = useWandererContext();
  const [tabs, setTabs] = useState([{ id: 1, label: "selected map" }]);
  const addNewTab = (e) => {
    e.preventDefault();
    const newTab = {
      id: Date.now(),
      label: "new selectedMap",
    };
    setTabs([...tabs, newTab]);
  };

  const removeTab = (id: number) => {
    setTabs(tabs.filter((t) => t.id !== id));
  };
  return (
    <section className="flex flex-col justify-center items-center w-full">
      <div className="flex w-full">
        {tabs.map((tab) => (
          <>
            <CombatTab key={tab.id} tab={tab} />
            <CustomButton onClick={() => removeTab(tab.id)}>x</CustomButton>
          </>
        ))}
        <CustomButton onClick={addNewTab}>+</CustomButton>
      </div>
      {/* TODO re-enable after implementing rounds
      <div className="flex justify-center">
        <span className="text-dark-key text-xl">rounds: </span>
        <span className="m-0.5 ml-1 text-dark-number">{1}</span>
        <span className="m-0.5">/</span>
        <span className="m-0.5 text-dark-number">{MAX_ROUNDS}</span>
      </div>
      */}
      <div className="flex justify-center w-1/2">
        <div className="text-2xl text-dark-type mr-2 mt-4">selected map</div>
      </div>
      {lastCombatResult !== undefined && <CombatRoundOutcome lastCombatResult={lastCombatResult} />}
      <CombatActions />
    </section>
  );
}
