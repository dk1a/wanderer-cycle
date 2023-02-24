import { useMemo } from "react";
import BaseInfo from "./BaseInfo";
import { useWandererContext } from "../../contexts/WandererContext";
import { pstatNames } from "../../mud/utils/experience";

export default function CombatInfo() {
  const { enemyEntity } = useWandererContext();

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
    <BaseInfo entity={enemyEntity} name={"Combat"} locationName={null} levelProps={levelProps} statProps={statProps} />
  );
}
