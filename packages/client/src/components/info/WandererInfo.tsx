import { useWandererContext } from "../../contexts/WandererContext";
import BaseInfo from "./BaseInfo";
import { useActiveGuise } from "../../mud/hooks/guise";
import { useLevel } from "../../mud/hooks/charstat";

export function WandererInfo() {
  const { cycleEntity } = useWandererContext();
  const guise = useActiveGuise(cycleEntity);
  const levelData = useLevel(cycleEntity, guise?.levelMul);

  return (
    <div className="top-16 h-full z-10">
      <BaseInfo entity={cycleEntity} name={"Wanderer"} locationName={null} levelData={levelData} />
    </div>
  );
}
