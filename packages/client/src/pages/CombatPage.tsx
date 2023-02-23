import CombatInfo from "../components/info/CombatInfo";
import CombatResultView from "../components/Combat/CombatResultView";
import Combat from "../components/Combat";
import { useWandererContext } from "../contexts/WandererContext";

const CombatPage = () => {
  const { enemyEntity } = useWandererContext();

  // TODO make this page only unreachable if enemyEntity !== undefined.This error should never trigger
  if (enemyEntity === undefined) {
    throw new Error("No active combat");
  }
  const withResult = false;

  return (
    <div className="w-full h-screen flex justify-center relative">
      {withResult ? (
        <div className="flex">
          <div className="w-full flex-grow">
            <CombatResultView
            // encounterResult={encounterResult}
            />
          </div>
        </div>
      ) : (
        <div className="flex">
          Map
          <div className="w-full flex-grow">
            <Combat />
          </div>
          <div className="w-64">
            <CombatInfo />
          </div>
        </div>
      )}
    </div>
  );
};

export default CombatPage;
