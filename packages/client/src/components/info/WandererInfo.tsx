import { useWandererContext } from "../../mud/WandererProvider";
import { BaseInfo } from "./BaseInfo";

export function WandererInfo() {
  const { selectedWandererEntity } = useWandererContext();

  return (
    <BaseInfo
      entity={selectedWandererEntity}
      name={"Wanderer"}
      locationName={null}
      levelData={{ level: undefined, experience: undefined }}
    />
  );
}
