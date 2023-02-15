import CombatInfo from "../components/Combat/CombatInfo";
import CombatResultView from "../components/Combat/CombatResultView";
import { useParams } from "react-router-dom";
import Combat from "../components/Combat";
import { useMemo } from "react";
import { pstatNames } from "../mud/utils/experience";
import { useWandererContext } from "../contexts/WandererContext";
import { useLifeCurrent } from "../mud/hooks/useLifeCurrent";
import { useManaCurrent } from "../mud/hooks/useManaCurrent";

const CombatPage = () => {
  const { enemyEntity } = useWandererContext();
  // TODO make this page only unreachable if enemyEntity !== undefined. This error should never trigger
  if (enemyEntity === undefined) {
    throw new Error("No active combat");
  }

  const lifeCurrent = useLifeCurrent(enemyEntity);
  const manaCurrent = useManaCurrent(enemyEntity);

  const withResult = false;
  const { id } = useParams();
  console.log(id);

  const statProps = useMemo(() => {
    return pstatNames.map((name) => {
      // TODO add pstat charstats
      return {
        name,
        props: { exp: null, level: 1, buffedLevel: 1 },
      };
    });
  }, []);

  const levelProps = useMemo(() => {
    // TODO add level charstat
    const level = 1;

    return {
      name: "level",
      props: { exp: null, level },
    };
  }, []);

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
          Map : {id}
          <div className="w-full flex-grow">
            <Combat />
          </div>
          <div className="w-64">
            <CombatInfo
              name={"Combat"}
              locationName={null}
              levelProps={levelProps}
              statProps={statProps}
              lifeCurrent={lifeCurrent}
              manaCurrent={manaCurrent}
            />
          </div>
        </div>
      )}
    </div>
  );
};

export default CombatPage;
