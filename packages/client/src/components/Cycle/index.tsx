import { useState } from "react";
import { CycleEnd } from "./CycleEnd";
import { CycleStart } from "./CycleStart";

export function Cycle() {
  const [isToggled, setIsToggled] = useState(false);

  return (
    <div className="flex justify-center w-full">
      {isToggled ? (
        <CycleStart isToggled={isToggled} setIsToggled={setIsToggled} />
      ) : (
        <CycleEnd isToggled={isToggled} setIsToggled={setIsToggled} />
      )}
    </div>
  );
}
