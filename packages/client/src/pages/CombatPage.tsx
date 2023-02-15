import CombatInfo from "../components/Combat/CombatInfo";
import CombatResultView from "../components/Combat/CombatResultView";
import { useParams } from "react-router-dom";
import Combat from "../components/Combat";
import { useMemo } from "react";
import { expToLevel, pstatNames } from "../mud/utils/experience";
import { useWandererContext } from "../contexts/WandererContext";
import { useActiveGuise } from "../mud/hooks/useActiveGuise";
import { useExperience } from "../mud/hooks/useExperience";
import { useCycleTurns } from "../mud/hooks/useCycleTurns";
import { useLifeCurrent } from "../mud/hooks/useLifeCurrent";
import { useManaCurrent } from "../mud/hooks/useManaCurrent";

const CombatPage = () => {
  const { cycleEntity } = useWandererContext();
  const guise = useActiveGuise(cycleEntity);
  const experience = useExperience(cycleEntity);
  const turns = useCycleTurns(cycleEntity);
  const lifeCurrent = useLifeCurrent(cycleEntity);
  const manaCurrent = useManaCurrent(cycleEntity);

  const withLocation = true;
  const withResult = true;
  const { id } = useParams();
  console.log(id);

  const statProps = useMemo(() => {
    return pstatNames.map((name) => {
      let exp, level, buffedLevel;
      if (experience) {
        (exp = experience[name]), (level = expToLevel(exp));
        // TODO add statmods data
        buffedLevel = level;
      }
      return {
        name,
        props: { exp, level, buffedLevel },
      };
    });
  }, [experience]);

  const levelProps = useMemo(() => {
    // TODO add total exp data
    const exp = 10;
    const level = 1;

    return {
      name: "level",
      props: { exp, level },
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
      ) : withLocation ? (
        <div className="flex">
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
      ) : (
        <div>{/*<Locations />*/}</div>
      )}
    </div>
  );
};

export default CombatPage;
