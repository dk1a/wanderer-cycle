import Combat from "../components/Combat";
import { useWandererContext } from "../contexts/WandererContext";

export default function CombatPage() {
  const { enemyEntity } = useWandererContext();

  // TODO make this page only unreachable if enemyEntity !== undefined.This error should never trigger
  if (enemyEntity === undefined) {
    throw new Error("No active combat");
  }

  return (
    <div className="w-full h-screen flex justify-center relative">
      <div className="flex">
        Map
        <div className="w-full flex-grow">
          <Combat />
        </div>
      </div>
    </div>
  );
}
