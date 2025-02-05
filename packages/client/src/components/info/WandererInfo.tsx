import { useWandererContext } from "../../contexts/WandererContext";
import BaseInfo from "./BaseInfo";

export function WandererInfo() {
  const { selectedWandererEntity } = useWandererContext();

  return (
    <div className="top-16 h-full z-10">
      <BaseInfo
        entity={selectedWandererEntity}
        name={"Wanderer"}
        locationName={null}
        levelData={undefined}
      />
    </div>
  );
}
