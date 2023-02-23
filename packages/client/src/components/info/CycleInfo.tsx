import { useMemo } from "react";
import BaseInfo from "./BaseInfo";
import PassTurnButton from "./PassTurnButton";
import ClaimTurnsButton from "./ClaimTurnsButton";
import { useActiveGuise } from "../../mud/hooks/useActiveGuise";
import { useExperience } from "../../mud/hooks/useExperience";
import { expToLevel, pstatNames } from "../../mud/utils/experience";
import { useCycleTurns } from "../../mud/hooks/useCycleTurns";
import { useWandererContext } from "../../contexts/WandererContext";

export default function CycleInfo() {
  const { cycleEntity } = useWandererContext();
  const guise = useActiveGuise(cycleEntity);
  const experience = useExperience(cycleEntity);
  const turns = useCycleTurns(cycleEntity);

  const levelProps = useMemo(() => {
    // TODO add total exp data
    const exp = 10;
    const level = 1;

    return {
      name: "level",
      props: { exp, level },
    };
  }, []);

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

  const isClaimTurnsAvailable = useMemo(() => {
    // TODO use proper availability
    return true;
  }, []);

  const turnsHtml = (
    <>
      <div className="flex ml-2">
        <div className="w-1/3 mr-5">
          <span className="text-dark-key">turns:</span>
          <span className="text-dark-number ml-1">{turns}</span>
        </div>
        {isClaimTurnsAvailable && (
          <div className="w-1/2 mr-0.5">
            <ClaimTurnsButton />
          </div>
        )}
      </div>
      <div className="flex w-full box-border w-48 m-1">
        <PassTurnButton />
      </div>
    </>
  );

  return (
    <div className="absolute top-16 left-0 h-[100vh]">
      <BaseInfo
        entity={cycleEntity}
        name={guise?.name}
        locationName={null}
        levelProps={levelProps}
        statProps={statProps}
        turnsHtml={turnsHtml}
      />
    </div>
  );
}
