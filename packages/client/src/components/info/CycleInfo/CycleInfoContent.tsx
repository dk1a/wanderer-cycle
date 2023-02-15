import { useMemo } from "react";
import BaseInfo from "../BaseInfo";
import PassTurnButton from "../PassTurnButton";
import ClaimTurnsButton from "../ClaimTurnsButton";
import { EntityIndex } from "@latticexyz/recs";
import { useActiveGuise } from "../../../mud/hooks/useActiveGuise";
import { useExperience } from "../../../mud/hooks/useExperience";
import { expToLevel, pstatNames } from "../../../mud/utils/experience";
import { useCycleTurns } from "../../../mud/hooks/useCycleTurns";
import { useLifeCurrent } from "../../../mud/hooks/useLifeCurrent";
import { useManaCurrent } from "../../../mud/hooks/useManaCurrent";
import classes from "../BaseInfo/info.module.scss";

export default function CycleInfoContent({ cycleEntity }: { cycleEntity: EntityIndex }) {
  const guise = useActiveGuise(cycleEntity);
  const experience = useExperience(cycleEntity);
  const turns = useCycleTurns(cycleEntity);
  const lifeCurrent = useLifeCurrent(cycleEntity);
  const manaCurrent = useManaCurrent(cycleEntity);
  console.log("cycleEntity", cycleEntity);
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

  const turnsHtml = (
    <>
      <div className={classes.turns__container}>
        <div className={classes.turns__name}>
          <span className={classes.turns__turns}>turns:</span>
          <span className={classes.turns__numbers}>{turns}</span>
        </div>
        <div className="w-1/2 mr-0.5">
          <ClaimTurnsButton turns={turns} />
        </div>
      </div>
      <div className={classes.turns__btn}>
        <PassTurnButton />
      </div>
    </>
  );

  return (
    <BaseInfo
      name={guise?.name}
      locationName={null}
      levelProps={levelProps}
      statProps={statProps}
      lifeCurrent={lifeCurrent}
      manaCurrent={manaCurrent}
      turnsHtml={turnsHtml}
    />
  );
}
