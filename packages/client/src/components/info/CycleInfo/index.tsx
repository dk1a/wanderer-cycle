import { useWandererContext } from "../../../contexts/WandererContext";
import CycleInfoContent from "./CycleInfoContent";

export default function CycleInfo() {
  const { cycleEntity } = useWandererContext();

  // TODO display some placeholder if this is even possible to reach
  if (!cycleEntity) {
    return <></>;
  }

  return <CycleInfoContent cycleEntity={cycleEntity} />;
}
