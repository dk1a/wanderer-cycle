import { Cycle } from "../components/Cycle";
import { WandererInfo } from "../components/info/WandererInfo";

export function CyclePage() {
  return (
    <div className="flex justify-between w-full z-20">
      <Cycle />
      <WandererInfo />
    </div>
  );
}
