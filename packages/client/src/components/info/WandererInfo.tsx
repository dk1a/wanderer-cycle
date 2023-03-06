import BaseInfo from "./BaseInfo";
import { useWandererContext } from "../../contexts/WandererContext";

export function WandererInfo() {
  const { cycleEntity } = useWandererContext();

  return (
    <div className="top-16 h-full z-10">
      <BaseInfo entity={cycleEntity} name={"Wanderer"} locationName={null} levelData={undefined} turnsHtml={null} />
    </div>
  );
}
